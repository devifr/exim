module Exim

    class Importer

      def self.extname_file(file)
        File.extname(file.filename)
      end

      def self.f_row
        1 || 0
      end

      def self.import_file(klass,file,key)
        spreadsheet = open_spreadsheet(file[:file])
        header = file[:sortable_schema].split(',')
        header_count = header.count - 1
        if header_count > 0 && header_count < spreadsheet.last_column
          insert_data(klass,key,spreadsheet,header,header_count)
        else
          return {errors: "Please Select Right Spreadsheet Header"}
        end
      end

      def self.nested_attributes(klass,row,id)
        klass.nested_attributes_options.keys.each do |nest|
          next if nest.to_s.pluralize == nest.to_s
          nested = eval(nest.to_s.pluralize.singularize.titleize)
          id_nested = klass.find(id)
          id_nested = id_nested.send("#{nest.to_s}").try(:id)
          data_nested = nested.find_or_initialize_by_id(id_nested)
          polymorphic_attr(klass,data_nested,id)
          data_nested.attributes = row.to_hash.slice(*nested.accessible_attributes)
          valid_save(data_nested,nested,row)
        end
      end

      def self.insert_data(klass,key,spreadsheet,header,header_count)
        (f_row+1..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)[0..header_count]].transpose]
          data = klass.send("find_or_initialize_by_#{key}",row[key])
          data.attributes = row.to_hash.slice(*klass.accessible_attributes)
          accessor(klass)
          valid_save(data,klass,row)
        end 
      end


      def self.accessor(klass)
        if klass.accessible_attributes.select{|a| a =~ /_ids\z/}.present?
          accessors = klass.accessible_attributes.select{|x| x =~ /_ids\z/}.each do |acc|
            accessors = acc.gsub '_ids', '_names'
            data.send("#{accessors}=",row[accessors])
          end
        end

        if klass.accessible_attributes.select{|a| a =~ /_id\z/}.present?
          accessor = klass.accessible_attributes.select{|x| x =~ /_id\z/}.each do |acc|
            accessor = acc.gsub '_id', '_name'
            data.send("#{accessor}=",row[accessor])
          end
        end
      end

      def self.polymorphic_attr(klass,data,id)
        unless data.attributes.keys.blank?
          poly = data.attributes.keys.select{|x| x =~ /able_type\z/}.first.gsub 'able_type', ''
          data.send("#{poly}able_id=", id)
          data.send("#{poly}able_type=", klass.to_s)
        end
      end

      def self.valid_save(data,klass,row)
        if data.valid?
          data.save
          id = data.id 
          nested_attributes(klass,row,id)
        end
      end

      def self.open_spreadsheet(file)
        case extname_file(file)
          when '.csv' then Roo::CSV.new(file.tempfile.path)
          when '.xls' then Roo::Excel.new(file.tempfile.path, :nil, :ignore)
          when '.xlsx' then Roo::Excelx.new(file.tempfile.path, :nil, :ignore)
        else 
          raise "Unknown File Type #{file.filename}"
        end
      end
  
  end

end