# Process::Pipeline

Provides a simple API for making composable shell-style pipelines.

[![Development Status](https://github.com/ioquatix/process-pipeline/workflows/Development/badge.svg)](https://github.com/ioquatix/process-pipeline/actions?workflow=Development)

## Installation

Add this line to your application's Gemfile:

	gem 'process-pipeline'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install process-pipeline

## Usage

You can create a basic pipeline:

```ruby
pipeline = Process::Pipeline.("head /dev/random").("strings").("wc -c")

puts pipeline.read.to_i
```

You can do more complex tasks:

```ruby
Process::Pipeline.("curl http://www.google.com").each_line.to_a
=> ["<HTML><HEAD><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">\n",
 "<TITLE>302 Moved</TITLE></HEAD><BODY>\n",
 "<H1>302 Moved</H1>\n",
 "The document has moved\n",
 "<A HREF=\"http://www.google.co.nz/?gfe_rd=cr&amp;dcr=0&amp;ei=vcLmWdihI6bu8we2qpD4Cg\">here</A>.\r\n",
 "</BODY></HTML>\r\n"]
```

### Output

You can write output to either a file or a pipe.

```ruby
pipeline = Process::Pipeline.("head /dev/random")

# Read all data until pipe is closed:
buffer = pipeline.read

# Read directly from pipe:
pipeline.read do |output|
	# Read 8 bytes:
	buffer = output.read(8)
end

# Write all data into a file:
pipeline.write("entropy.dat")
```

### Input

Input can be either a file or a pipe.

```ruby
pipeline = Process::Pipeline.("head")

pipeline.read(input: "/usr/share/dict/words")
=> "A\na\naa\naal\naalii\naam\nAani\naardvark\naardwolf\nAaron\n"
```

Using a pipe can be a bit more tricky since you need to feed data into it incrementally.

```ruby
pipeline = Process::Pipeline.("sort")

output, input = IO.pipe

thread = Thread.new do
	%w{The quick brown fox jumps over the lazy dog}.each do |word|
		input.puts word
	end
	
	input.close
end

# The input to the command is the output of the pipe
buffer = pipeline.read(input: output)

expect(buffer).to be == "The\nbrown\ndog\nfox\njumps\nlazy\nover\nquick\nthe\n"

thread.join
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2013, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
