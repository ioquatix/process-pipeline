# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'command_error'
require 'process/group'

module Process
	module Pipeline
		Step = Struct.new(:tail, :command) do
			def dup(tail)
				self.class.new(self.tail&.dup(tail) || tail, self.command)
			end
			
			def call(*command)
				self.class.new(self, command)
			end
			
			def spawn(group, input, output, error)
				if self.command.nil?
					return self.tail&.call(group, input, output, error)
				end
				
				if Hash === self.command.last
					*command, options = self.command
				else
					command = self.command
					options = {}
				end
				
				if self.tail
					pipe = IO.pipe
					
					self.tail.spawn(group, input, pipe[1], error)
					pipe[1].close
					
					options[:in] = pipe[0]
				end
				
				options[:out] = output
				
				group.run(*command, **options) do |exit_status|
					unless exit_status.success?
						raise CommandError, self, exit_status
					end
				end
			end
			
			def read(input: nil, error: $stderr)
				pipe = IO.pipe
				
				Process::Group.wait do |group|
					self.spawn(group, input, pipe[1], error)
				end
				
				pipe[1].close
				buffer = pipe[0].read
				pipe[0].close
				
				return buffer
			end
			
			def write(path, input: nil, error: $stderr)
				File.open(path, "w") do |file|
					Process::Group.wait do |group|
						self.spawn(group, input, file, error)
					end
				end
				
				return self
			end
			
			def each(&block)
				return to_enum unless block_given?
				
				if self.tail
					self.tail.each(&block)
				end
				
				yield self
			end
			
			def to_s
				if self.command
					self.command.join(" ")
				else
					nil
				end
			end
			
			def inspect
				self.each.collect(&:to_s).join(" | ")
			end
			
			def + pipeline
				pipeline.dup(self)
			end
		end
	end
end
