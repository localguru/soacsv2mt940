#!/usr/bin/env ruby

# NAME: soamt940 -- Mapping statement of account .mt940 file

module SOACSV2MT940
  
  class SOAMT940

    def initialize(csv_data, filename_mt940, soa_nbr, soa_opening_balance)
      @csv_data = csv_data
      @filename_mt940 = filename_mt940
      @soa_nbr = soa_nbr
      @soa_opening_balance = soa_opening_balance
      @soa_closing_balance = @soa_opening_balance
      filename_index = 0
      while File.exists? @filename_mt940 
        filename_index += 1
        @filename_mt940 = @filename_mt940 + ".#{filename_index.to_s}"
      end
    end
  
    def csv2mt940
      puts "Konvertierung Commerzbank .csv-Kontoauszugsdatei ins Format .mt940 (SWIFT):"
      write_header
      write_body
      write_footer
    end
      
    def write_header
      puts "- Eröffnungs-Saldo: #{sprintf("%#.2f", @soa_opening_balance)}"
      write_record_type_20
      write_record_type_21
      write_record_type_25
      write_record_type_28
      write_record_type_60
    end
    
    def write_body
      nbr_of_relevant_rows = 0
      @csv_data.each do |csv_record|
        if csv_record
          write_record_type_61(csv_record)
          write_record_type_86(csv_record)
          @soa_closing_balance += csv_record[:betrag].gsub(",", ".").to_f
          nbr_of_relevant_rows += 1
        end
      end
      puts "- Umsatz-relevante Datensätze: #{nbr_of_relevant_rows}"
    end
    
    def write_footer
      write_record_type_62
      puts "- Schluß-Saldo: #{sprintf("%#.2f", @soa_closing_balance)}"
    end
    
    def write_record_type_20
      record_type_20 = ":20:SOACSV2MT940"
      write_mt940(record_type_20)
    end
    
    def write_record_type_21
      record_type_21 = ":21:NONREF"
      write_mt940(record_type_21)
    end
    
    def write_record_type_25    
      record_type_25 = ":25:#{@csv_data[1][:auftraggeber_blz]}/#{@csv_data[1][:auftraggeber_konto]}"
      write_mt940(record_type_25)
      puts "- BLZ/Konto: #{@csv_data[1][:auftraggeber_blz]} / #{@csv_data[1][:auftraggeber_konto]}"
    end
    
    def write_record_type_28
      record_type_28 = ":28C:#{@soa_nbr}"
      write_mt940(record_type_28)
    end
    
    def write_record_type_60
      if @soa_opening_balance >= 0
        credit_debit = "C"
      else
        credit_debit = "D"
      end
      buchungsdatum = Date.strptime(@csv_data[1][:buchungstag], '%d.%m.%Y')
      record_type_60 = ":60F:#{credit_debit}#{buchungsdatum.strftime('%y%m%d')}EUR#{sprintf("%#.2f", @soa_opening_balance).to_s.gsub(".", ",")}"
      write_mt940(record_type_60)
      puts "- Kontoauszugsdatum: #{buchungsdatum}"
    end
    
    def write_record_type_61(csv_record)
      buchungsdatum = Date.strptime(csv_record[:buchungstag], '%d.%m.%Y')
      valutadatum = Date.strptime(csv_record[:wertstellung], '%d.%m.%Y')
      betrag = csv_record[:betrag].gsub(",", ".").to_f
      if betrag >= 0
        credit_debit = "C"
      else
        credit_debit = "D"
        betrag *= -1
      end
      betrag = sprintf("%#.2f", betrag).to_s.gsub(".", ",")
      record_type_61 = ":61:#{valutadatum.strftime('%y%m%d')}#{buchungsdatum.strftime('%m%d')}#{credit_debit}#{betrag}NONREF"
      write_mt940(record_type_61)
    end

    def write_record_type_62
      if @soa_closing_balance >= 0
        credit_debit = "C"
      else
        credit_debit = "D"
        @soa_closing_balance *= -1
      end
      buchungsdatum = Date.strptime(@csv_data[1][:buchungstag], '%d.%m.%Y')  
      record_type_62 = ":62F:#{credit_debit}#{buchungsdatum.strftime('%y%m%d')}EUR#{sprintf("%#.2f", @soa_closing_balance).to_s.gsub(".", ",")}" 
      write_mt940(record_type_62)
    end
    
    def write_record_type_86(csv_record)
      gvc = "999"
      buchungstext = convert_umlaute(csv_record[:buchungstext]).gsub('"', '')
      umsatzart = convert_umlaute(csv_record[:umsatzart]).upcase
      record_type_86 = ":86:#{gvc}#{umsatzart}:#{buchungstext}"
      write_mt940(record_type_86)
    end
  
    def write_mt940(record)
      File.open(@filename_mt940 , "a") do |file|
        file.puts record
      end
    end
    
    def convert_umlaute(text)
      text = text.gsub('ä','ae').gsub('Ä','AE').gsub('ö','oe').gsub('Ö','OE').gsub('ü','ue').gsub('Ü','UE').gsub('ß','ss')
    end
     
  end

end