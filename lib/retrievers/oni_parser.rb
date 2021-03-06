class ONIParser
    require 'csv'
    RATING_MAP = {
        'Low' => 0.0,
        'Medium' => 1.0,
        'High' => 2.0
    }

    def data(options = {})
        filename = options[:filename]
        column = options[:column]
        normalized_column = options[:normalized_column]
        data = []
        csv = CSV.open(filename, { :headers => true })
        csv.each do |row|
            country = Country.find_by_iso_code(row['country_code'])
            next unless country

            start_date = Date.new(row['testing_date'].to_i, 1, 1)
            if ['transparency', 'consistency'].include? column
                datum = RATING_MAP[row[column]]
                normalized = RATING_MAP[row[normalized_column]]
            else
                datum = row[column].to_f
                normalized = row[normalized_column].to_f
            end
            unless datum.nil?
                i = Indicator.new(:start_date => start_date, :original_value => datum, :value => normalized)
                i.country = country
                data << i
            end
        end
        data
    end
end

