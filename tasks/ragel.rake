file "lib/fogbugz_svnhook/parser.rb" => "lib/fogbugz_svnhook/parser_machine.rb" do
  sh "ragel -R lib/fogbugz_svnhook/parser_machine.rb -o lib/fogbugz_svnhook/parser.rb"
end

file "tmp/machine.dot" => "lib/fogbugz_svnhook/parser_machine.rb" do
  sh "ragel -V lib/fogbugz_svnhook/parser_machine.rb -o tmp/machine.dot"
end

file "website/machine.png" => "tmp/machine.dot" do
  sh "dot -Tpng tmp/machine.dot > website/machine.png"
end

namespace :ragel do
  desc "Compile the Ragel state machine to executable Ruby code"
  task :compile => "lib/fogbugz_svnhook/parser.rb"

  desc "Generate website/machine.png"
  task :graph => "website/machine.png"

  desc "Delete generated Ragel files"
  task :clean do
    rm_f "lib/fogbugz_svnhook/parser.rb"
    rm_f "tmp/machine.dot"
    rm_f "website/machine.png"
  end
end

task :ragel => %w(ragel:compile ragel:graph)
