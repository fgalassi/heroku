require "spec_helper"
require "heroku/command/ps"

describe Heroku::Command::Ps do

  before(:each) do
    stub_core
  end

  context("cedar") do

    before(:each) do
      now = Time.now
      Time.should_receive(:now).any_number_of_times.and_return(now)
      api.post_app("name" => "myapp", "stack" => "cedar")
    end

    after(:each) do
      api.delete_app("myapp")
    end

    it "ps:dynos errors out on cedar apps" do
      lambda { execute("ps:dynos") }.should raise_error(Heroku::Command::CommandFailed, "For Cedar apps, use `heroku ps`")
    end

    it "ps:workers errors out on cedar apps" do
      lambda { execute("ps:workers") }.should raise_error(Heroku::Command::CommandFailed, "For Cedar apps, use `heroku ps`")
    end

    describe "ps" do

      it "displays processes" do
        stderr, stdout = execute("ps")
        stderr.should == ""
        stdout.should == <<-STDOUT
=== `bundle exec thin start -p $PORT`
web.1: created for 0s

STDOUT
      end

    end

    describe "ps:restart" do

      it "restarts all processes with no args" do
        stderr, stdout = execute("ps:restart")
        stderr.should == ""
        stdout.should == <<-STDOUT
Restarting processes... done
STDOUT
      end

      it "restarts one process" do
        stderr, stdout = execute("ps:restart web.1")
        stderr.should == ""
        stdout.should == <<-STDOUT
Restarting web.1 process... done
STDOUT
      end

      it "restarts a type of process" do
        stderr, stdout = execute("ps:restart web")
        stderr.should == ""
        stdout.should == <<-STDOUT
Restarting web processes... done
STDOUT
      end

    end

    describe "ps:scale" do

      it "can scale using key/value format" do
        stderr, stdout = execute("ps:scale web=5")
        stderr.should == ""
        stdout.should == <<-STDOUT
Scaling web processes... done, now running 5
STDOUT
      end

      it "can scale relative amounts" do
        stderr, stdout = execute("ps:scale web+2")
        stderr.should == ""
        stdout.should == <<-STDOUT
Scaling web processes... done, now running 3
STDOUT
      end

    end

    describe "ps:stop" do

      it "restarts one process" do
        stderr, stdout = execute("ps:restart ps.1")
        stderr.should == ""
        stdout.should == <<-STDOUT
Restarting ps.1 process... done
STDOUT
      end

      it "restarts a type of process" do
        stderr, stdout = execute("ps:restart ps")
        stderr.should == ""
        stdout.should == <<-STDOUT
Restarting ps processes... done
STDOUT
      end

    end

  end

  context("non-cedar") do

    before(:each) do
      api.post_app("name" => "myapp")
    end

    after(:each) do
      api.delete_app("myapp")
    end

    describe "ps:dynos" do

      it "displays the current number of dynos" do
        stderr, stdout = execute("ps:dynos")
        stderr.should == ""
        stdout.should == <<-STDOUT
~ `heroku ps:dynos QTY` has been deprecated and replaced with `heroku ps:scale dynos=QTY`
myapp is running 0 dynos
STDOUT
      end

      it "sets the number of dynos" do
        stderr, stdout = execute("ps:dynos 5")
        stderr.should == ""
        stdout.should == <<-STDOUT
~ `heroku ps:dynos QTY` has been deprecated and replaced with `heroku ps:scale dynos=QTY`
Scaling dynos... done, now running 5
STDOUT
      end

    end

    describe "ps:workers" do

      it "displays the current number of workers" do
        stderr, stdout = execute("ps:workers")
        stderr.should == ""
        stdout.should == <<-STDOUT
~ `heroku ps:workers QTY` has been deprecated and replaced with `heroku ps:scale workers=QTY`
myapp is running 0 workers
STDOUT
      end

      it "sets the number of workers" do
        stderr, stdout = execute("ps:workers 5")
        stderr.should == ""
        stdout.should == <<-STDOUT
~ `heroku ps:workers QTY` has been deprecated and replaced with `heroku ps:scale workers=QTY`
Scaling workers... done, now running 5
STDOUT
      end

    end

  end

end
