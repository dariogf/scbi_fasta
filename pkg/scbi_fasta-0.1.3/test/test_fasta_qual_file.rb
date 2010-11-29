require File.dirname(__FILE__) + '/test_helper.rb'

class TestFastaQualFile < Test::Unit::TestCase


   def setup
   	@test_file='/tmp/fbinfile';
  	
  	@seq_fasta='ACTG'
		@seq_qual=[25]
	  @seq_name='SEQ'
  	 
   end
  
  	 
  def fill_file(n)
  	f=File.new(@test_file+'.fasta','w')
  	q=File.new(@test_file+'.qual','w')
  	
  	n.times do |c|
  	  i = c+1
  	  name = ">#{@seq_name+i.to_s} comments"
  	  
  		f.puts(name)
  		f.puts(@seq_fasta*i)
  		
  		q.puts(name)
  		q.puts((@seq_qual*i*@seq_fasta.length).join(' '))
  		
  		
  	end
  	
  	f.close
  	q.close
  end
  
  def test_next_seq

    	 # make new file and fill with data
		  fill_file(100) 	
		

			fqr=FastaQualFile.new(@test_file+'.fasta',@test_file+'.qual')
			n,s,q = ['']*3
			i=0
			
    	100.times do |c|
    		i = c+1
				n,s,q = fqr.next_seq
				
				#puts n,s.length,q.split(' ').length
			  assert(@seq_name+i.to_s==n)
			  assert(@seq_fasta*i==s)
			  assert((@seq_qual*i*@seq_fasta.length).join(' ')==q)

			end
			 
		  fqr.close			
		  
  		rescue Exception => e
	  		 puts "failed in #{n} , #{s}, #{q}"
	  		 puts "expected #{@seq_name+i.to_s} , #{@seq_fasta*i==s}, #{(@seq_qual*i*@seq_fasta.length).join(' ')}"
	  			puts e.message, e.backtrace

   end

  def test_each

    	 # make new file and fill with data
		  fill_file(100) 	
		

			fqr=FastaQualFile.new(@test_file+'.fasta',@test_file+'.qual')

			i=1
			n,s,q = ['']*3
			
			fqr.each do |n,s,q|

				#puts n,s.length,q.split(' ').length
			  assert(@seq_name+i.to_s==n)
			  assert(@seq_fasta*i==s)
			  assert((@seq_qual*i*@seq_fasta.length).join(' ')==q)

				i+=1
			end
			 
		  fqr.close			
		  
  		rescue Exception => e
	  		 puts "failed in #{n} , #{s}, #{q}"
	  		 puts "expected #{@seq_name+i.to_s} , #{@seq_fasta*i==s}, #{(@seq_qual*i*@seq_fasta.length).join(' ')}"
	  		 puts e.message, e.backtrace

   end
   
   def test_next_seq_only_fasta

    	 # make new file and fill with data
		  fill_file(100) 	
		

			fqr=FastaQualFile.new(@test_file+'.fasta')
			n,s = ['']*2
			i=0
			
    	100.times do |c|
    		i = c+1
				n,s,q = fqr.next_seq
				
				#puts n,s.length,q.split(' ').length
			  assert(@seq_name+i.to_s==n)
			  assert(@seq_fasta*i==s)
			  assert(q.nil?)

			end
			 
		  fqr.close			
		  
  		rescue Exception => e
	  		 puts "failed in #{n} , #{s}"
	  		 puts "expected #{@seq_name+i.to_s} , #{@seq_fasta*i==s}"
	  			puts e.message, e.backtrace

   end

   
   def test_each_only_fasta

			count=100
    	 # make new file and fill with data
		  fill_file(count) 	
		

			fqr=FastaQualFile.new(@test_file+'.fasta')

			i=1
			n,s = ['']*2
			
			fqr.each do |n,s,q|

				#puts n,s.length,q.split(' ').length
			  assert(@seq_name+i.to_s==n)
			  assert(@seq_fasta*i==s)
			  
			  assert(q.nil?)
			  
				i+=1
			end
			
			assert(i==count+1)
			 
		  fqr.close			
		  
  		rescue Exception => e
	  		 puts "failed in #{n} , #{s}"
	  		 puts "expected #{@seq_name+i.to_s} , #{@seq_fasta*i==s}"
	  		 puts e.message, e.backtrace

   end


end
