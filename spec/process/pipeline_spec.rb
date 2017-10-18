require "spec_helper"

RSpec.describe Process::Pipeline do
	it "can execute basic pipeline and read output" do
		pipeline = Process::Pipeline.("cat Rakefile").("strings").("sort")
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
end
