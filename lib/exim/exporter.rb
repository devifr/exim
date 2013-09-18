module Exim

  module Exporter
    
    def self.to_csv(klass)
      CSV.generate do |csv|
        value_attr(klass,csv)
      end
    end

    def self.value_attr(klass,csv)
      header_attr(klass,csv)
      body_attr(klass,csv)
    end

    def self.header_attr(klass,csv)
      if klass.nested_attributes_options.keys.present?
        klass.nested_attributes_options.keys.each do |nest|
          next if nest.to_s.pluralize == nest.to_s
          nested = eval(nest.to_s.pluralize.singularize.titleize)
          header_column = klass.accessible_attributes
          nested_accessible = nested.accessible_attributes
          to_name(header_column)
          delete_attributes(header_column)
          delete_attributes(nested_accessible,header_column)
          to_name(nested_accessible)
          more_accessible = more_nested_header(nested)
          header_attributes = (header_column + nested_accessible)
          header_attributes = header_attributes + more_accessible if more_accessible
          csv << header_attributes
        end
      else
        header_column = klass.accessible_attributes
        delete_attributes(header_column)
        to_name(header_column)
        csv << header_column
      end
    end

    def self.more_nested_header(nested)
      if nested.nested_attributes_options.keys.present?
        nested.nested_attributes_options.keys.each do |nest|
          next if nest.to_s.pluralize == nest.to_s
          other_nested = eval(nest.to_s.pluralize.singularize.titleize)
          nested_accessible = nested.accessible_attributes
          other_nested_accessible = other_nested.accessible_attributes
          delete_attributes(other_nested_accessible,nested_accessible)
          to_name(other_nested_accessible)
          return other_nested_accessible
        end
      else
        return nil
      end
    end

    def self.to_name(attributes)
      attributes.select{|x| x =~ /_id\z/}.each do |old_name|
        attributes.delete(old_name)
        attributes << old_name.gsub('_id',' name')
      end
      attributes.select{|x| x =~ /_ids\z/}.each do |old_name|
        attributes.delete(old_name)
        attributes << old_name.gsub('_ids',' names')
      end
    end

    def self.delete_attributes(attributes,parent_attributes=nil)
      attributes.select{|x| x =~ /_attributes\z/}.each do |nested_access|
        attributes.delete(nested_access)
      end
      if parent_attributes
        attributes.each do |nested_accessible|
          if parent_attributes.include?(nested_accessible)
            attributes.delete(nested_accessible)
          end
        end
      end
    end
    def self.body_attr(klass,csv)
      datas = klass.all
      datas.each do |data|
        value_data = value_data_attr(klass,data)
        if klass.nested_attributes_options.keys.present?
          klass.nested_attributes_options.keys.each do |nest|
            next if nest.to_s.pluralize == nest.to_s
            nested = eval(nest.to_s.pluralize.singularize.titleize)
            id = data.attributes.values_at("id")
            id_nested = klass.find(id[0])
            id_nested = id_nested.send("#{nest.to_s}").try(:id)
            data_nested = nested.find_or_initialize_by_id(id_nested)
            value_nested = data_nested.attributes.values_at(*nested.accessible_attributes)
            more_nested_value = more_nested_body(nested,id_nested)
            value_nested = value_nested.concat(more_nested_value) if more_nested_value
            csv << value_data.concat(value_nested)
          end
        else
          csv << value_data
        end
      end
    end

    def self.value_data_attr(klass,data)
      if klass.accessible_attributes.select{|x| x =~ / name\z/}.present?
        klass.accessible_attributes.select{|x| x =~ / name\z/}.each do |accessor_attr|
          attr_access = accessor_attr.gsub(' name','')
          accessor = Hash.new
          if data.send("#{attr_access}")
            name_accessor = data.send("#{attr_access}").attributes["title"] || data.send("#{attr_access}").attributes["name"]
            accessor[accessor_attr] = name_accessor
          end
          other_accessor = value_datas_attr(klass,data)
          return value_data = data.attributes.merge(accessor).merge(other_accessor).values_at(*klass.accessible_attributes)  
        end
      else
        return value_data = data.attributes.values_at(*klass.accessible_attributes)  
      end    
    end

    def self.value_datas_attr(klass,data)
      accessor = Hash.new
      if klass.accessible_attributes.select{|x| x =~ / names\z/}.present?
        klass.accessible_attributes.select{|x| x =~ / names\z/}.each do |accessor_attr|
        attr_access = accessor_attr.gsub(' name','')
          unless data.send("#{attr_access}").blank?
            attr_name = Array.new
            name_accessor = data.send("#{attr_access}").each do |e|
               attr_name.push(e.name)
               accessor[accessor_attr] = attr_name.join(',')
            end
          end
        end
      end
      return accessor
    end

    def self.more_nested_body(nested,id)
      if nested.nested_attributes_options.keys.present?
        nested.nested_attributes_options.keys.each do |nest|
          next if nest.to_s.pluralize == nest.to_s
          other_nested = eval(nest.to_s.pluralize.singularize.titleize)
          datas = nested.all
          datas.each do |data|
            id_nested = nested.find(id)
            id_nested = id_nested.send("#{nest.to_s}").try(:id)
            data_nested = other_nested.find(id_nested)
            return other_value_nested = data_nested.attributes.values_at(*other_nested.accessible_attributes)
          end
        end
      else
        return nil
      end
    end

  end

end