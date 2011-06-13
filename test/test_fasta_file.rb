require File.dirname(__FILE__) + '/test_helper.rb'

class TestFastaFile < Test::Unit::TestCase

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

  def test_each

    # make new file and fill with data
    fill_file(100)

    fqr=FastaFile.new(@test_file+'.fasta')

    i=1


    fqr.each do |n,s|

      #puts n,s.length,q.split(' ').length
      assert(@seq_name+i.to_s==n)
      assert(@seq_fasta*i==s)

      i+=1
    end

    fqr.close

  rescue Exception => e
    puts "failed in #{n} , #{s}"
    puts "expected #{@seq_name+i.to_s} , #{@seq_fasta*i==s}"

    puts e.message, e.backtrace

  end

end
