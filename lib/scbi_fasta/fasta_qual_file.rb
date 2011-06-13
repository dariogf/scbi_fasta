
########################################################
# Author: Almudena Bocinos Rioboo                      
# 
# Reads a fasta file and qual file, and then fires events to process it
# 
#
# 
########################################################

class DifferentNamesException < RuntimeError 
end

class DifferentSizesException < RuntimeError
end

class FastaQualFile

attr_accessor :num_seqs, :end_fasta

  #------------------------------------
  # Initialize instance
  #------------------------------------
  def initialize(fasta_file_name,qual_file_name='',qual_to_array=false)

  	
  	if !File.exist?(fasta_file_name)
    	raise "File #{fasta_file_name} doesn't exists" 
  	end
  	
  	@with_qual = true
  	
  	if qual_file_name.nil? or qual_file_name.empty? or !File.exist?(qual_file_name)
  		@with_qual = false
      #raise "File #{qual_file_name} doesn't exists" 
  	end
  
  		
      @num_seqs = 0 ;      
      
      @seq_name = '';      
      @file_fasta = File.open(fasta_file_name) ;
      @end_fasta=false;
      
      if @with_qual  		
      
        @qual_to_array = qual_to_array

	      @seq_qual_name='';
	      @file_qual = File.open(qual_file_name) ;
	      @end_qual=false;
      end
      
  end
  
  def close
      @file_fasta.close
      
      @file_qual.close if @with_qual
  end
 
  
  #------------------------------------
  # Scans all sequences
  #------------------------------------
  def each
        
    rewind

	  n,f,q=next_seq
    while (!n.nil?)
	  
					if @with_qual
						yield(n,f,q)
					else
					  yield(n,f)
					end
					
  				n,f,q=next_seq
    end

  	rewind
  	
  end


  def rewind
     
     @num_seqs = 0 ;      
     
     @seq_name = '';      
     @file_fasta.pos=0
     @end_fasta=false;

     if @with_qual
				 @seq_qual_name='';
				 @file_qual.pos=0
				 @end_qual=false;   
     end
    
  end

  #------------------------------------
  # Scans a file, firing events to process content
  #------------------------------------
  def next_seq
    
    #init variables
    res = nil
    
	  # envia on_process_sequence
    if ((!@end_fasta) && (!@with_qual or !@end_qual))

	      name_f,fasta=read_fasta 
  	    
        if @with_qual
					  
					  name_q,qual=read_qual 
					  
            if (name_f!=name_q)
							 raise DifferentNamesException.new, "Sequence(<#{name_f}>) and qual(<#{name_q}>) names differs. Sequence will be ignored."
             else
							@num_seqs=@num_seqs+1
				
							#storage a string of qualities in an array of qualities
				 	    # a_qual = qual.strip.split(/\s/).map{|e| e.to_i}
							# if ((!a_qual.nil?) && (!a_qual.empty?) && (fasta.size==a_qual.size))						

							if fasta.length == qual.count(' ') + 1
								if @qual_to_array
									a_qual = qual.strip.split(/\s/).map{|e| e.to_i}
									res =[name_f,fasta,a_qual]
								else
									res =[name_f,fasta,qual]
								end
						
							else #if (!a_qual.empty?)
								 raise DifferentSizesException.new,  "Sequence(<#{name_f}>) and qual(<#{name_q}>) sizes differs (#{fasta.length},#{qual.count(' ')} ). Sequence will be ignored."
							end 
						 
            end
				 
        else # without qual				 
				 		res =[name_f,fasta]
        end
    end
  	
  	return res
  end
  
  def with_qual?
    @with_qual
  end

  
  private 
  
  #------------------------------------
  #  Read one sequence fasta
  #------------------------------------
  
  def read_fasta
    seq_fasta='';
    res = nil
    
    # mientras hay lineas en el fichero
    while (!@file_fasta.eof)        
      # $LOG.debug "Total fasta #{@seq_fasta} Line fast #{@line_fasta} "

      # lee una linea
      line_fasta = @file_fasta.readline; line_fasta.chomp!
      # si llega a fin de ficheor, poner eof
      @end_fasta=@file_fasta.eof

      # si la linea es una nueva secuencia
      if ((line_fasta =~ /^>/)) 
        
        # puede ocurrir que antes ya se hubiese leido una secuencia, entonces devolverla
        if !@seq_name.empty?
          # ya había leido una
          #puts "leida #{@seq_name} + #{@seq_fasta}"
          res = [@seq_name,seq_fasta]
        end


        #get only name
        line_fasta.gsub!(/^>\s*/,'');
        
        line_fasta =~ /(^[^\s]+)/
        # remove comments
        
        @seq_name = $1
        
        seq_fasta='';
        
        # si hay algo que devolver, romper bucle
        if res
          break
        end
        
      else # no es una linea de nombre, añadir al fasta
	      line_fasta.strip! if !line_fasta.empty?
        #add line to fasta of seq
        seq_fasta+=line_fasta;
        seq_fasta.strip! if !seq_fasta.empty?
      end 
       
        
    end
    
    
    #si no hay más secuencias hay que devolver la última, CASO EOF
    if res.nil? and !@seq_name.empty?
      res= [@seq_name,seq_fasta]
    end
    
    return res
  end
  
  #----
 
  #------------------------------------
  # Read one sequence qual
  #------------------------------------
  def read_qual
    seq_qual='';
    res = nil
    
    # mientras hay lineas en el fichero
    while (!@file_qual.eof)        
      # $LOG.debug "Total fasta #{@seq_qual} Line fast #{@line_qual} "

      # lee una linea
      line_qual = @file_qual.readline; line_qual.chomp!
      # si llega a fin de ficheor, poner eof
      @end_qual=@file_qual.eof

      # si la linea es una nueva secuencia
      if ((line_qual =~ /^>/)) 
        
        # puede ocurrir que antes ya se hubiese leido una secuencia, entonces devolverla
        if !@seq_qual_name.empty?
          # ya había leido una
          #puts "leida #{@seq_name} + #{@seq_qual}"

          seq_qual.gsub!(/\s\s+/,' ')	
          res = [@seq_qual_name,seq_qual]
        end

        
        #get only name
                #get only name
        line_qual.gsub!(/^>\s*/,'');
        
        line_qual =~ /(^[^\s]+)/
        # remove comments

        @seq_qual_name = $1
        seq_qual='';
        
        # si hay algo que devolver, romper bucle
        if res
          break
        end
        
      else # no es una linea de nombre, añadir al fasta
	      line_qual.strip! if !line_qual.empty?
        #add line to qual of seq
        seq_qual=seq_qual+' '+line_qual
        seq_qual.strip! if !seq_qual.empty?
      end 
      
    end
    
    
    #si no hay más secuencias hay que devolver la última, CASO EOF
    if res.nil? and !@seq_qual_name.empty?
      seq_qual.gsub!(/\s\s+/,' ')	
      res= [@seq_qual_name,seq_qual]
    end
    
    return res
  end  
  
  

  
end
