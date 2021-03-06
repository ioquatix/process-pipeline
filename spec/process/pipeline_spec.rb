
require 'process/pipeline'

RSpec.describe Process::Pipeline do
	let(:path) {File.expand_path("words.txt", __dir__)}
	
	it "can execute basic pipeline and read output" do
		pipeline = Process::Pipeline.("cat", path).("strings").("sort")
		buffer = nil
		
		buffer = pipeline.read
		
		expect(buffer).to_not be_nil
		expect(buffer).to_not be_empty
	end
	
	it "can join two pipelines together" do
		ab = Process::Pipeline.("echo a").("echo b")
		cd = Process::Pipeline.("echo c").("echo d")
		
		expect(ab + cd).to be == Process::Pipeline.("echo a").("echo b").("echo c").("echo d")
	end
	
	it "can read some lines" do
		pipeline = Process::Pipeline.("head").("sort")
		
		words = pipeline.each_line(input: path).to_a
		
		expect(words).to_not be_empty
		expect(words.first).to be == "brown\n"
	end
	
	it "can feed data into pipeline using a thread" do
		pipeline = Process::Pipeline.("sort")

		output, input = IO.pipe

		Thread.new do
			%w{the quick brown fox jumps over the lazy dog}.each do |word|
				input.puts word
			end
			
			input.close
		end

		# The input to the command is the output of the pipe
		buffer = pipeline.read(input: output)
		
		expect(buffer).to be == "brown\ndog\nfox\njumps\nlazy\nover\nquick\nthe\nthe\n"
	end
end
