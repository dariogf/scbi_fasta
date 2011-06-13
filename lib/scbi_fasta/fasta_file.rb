########################################################
# Author: Almudena Bocinos Rioboo                      
# Use: Deprecated. The class FastaReader has been substituted by FastaQualReader  
# Reads a fasta file and fires events to process it
# 
########################################################

class FastaFile
    
	attr  :num_seqs


    # Initialize instance
    def initialize(file_name)
      if File.exist?(file_name)
		    @num_seqs = 0

		    @file_name = file_name
		    @file = File.open(file_name)
		  else
		  		raise "File #{file_name} doesn't exists" 
      	
      end
      
    end
    

    # Scans a file, firing events to process content
    def each
      
      #init variables
      seq_name = '';
      seq_fasta = '';
      seq_found = false;
    
      
      # for each line of the file
      @file.each do |line|
        
        line.chomp!;
        # if line is name
        if line =~ /^>/
          
          #process previous sequence
          if seq_found
			      @num_seqs=@num_seqs+1
            yield(seq_name,seq_fasta);
          end
          
          #get only name

		     #get only name
	        line.gsub!(/^>\s*/,'');
        
	        line =~ /(^[^\s]+)/

	        # remove comments
	        seq_name = $1

          seq_fasta='';
          seq_found = true;
          
        else

		      line.strip! if !line.empty?
	
          #add line to fasta of seq
          seq_fasta+=line;

		      seq_fasta.strip! if !seq_fasta.empty?
		  
        end
          
      end
    
      # when found EOF, process last sequence
      if seq_found
			@num_seqs=@num_seqs+1
        yield(seq_name,seq_fasta);
      end
    end
    
    
    def close
    	@file.close
    end
    
    def with_qual?
      false
    end
    
end
