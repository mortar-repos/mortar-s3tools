## Mortar Example Plugin ##

This repository serves the purpose of being an template plugin for the [Mortar Development Framework](https://github.com/mortardata/mortar). Every file in this repository has comments explaining its purpose.

### Plugin Structure Overview ###

Mortar plugins are very flexible in their structure. There is only one required file, `init.rb` at the plugin root. This file is what Mortar uses to load your plugin. Optionally you can provide a Gemfile at the project root to list your plugin's specific dependencies. Mortar will use bundler to install a sandboxed environment for your application in the `~/.mortar/plugins/YOU_PLUGIN` directory.

A typical `init.rb` file will simply load the file that will be the command you're adding. Everything else should be loaded lazily when you command is actually called. That way your plugin won't slow down the entire development framework.

Although not required, it is suggested that you follow the basic directory structure in this example plugin. It's structure is based off the directory strucutre of the Mortar Development Framework.

### Creating your own command ###

To create a command, all you need to do is create a class that extends ```ruby Mortar::Command::Base``` and make sure its required in your `init.rb`. For example:

```ruby
require "mortar/command/base"

# An example command used for demoing mortar plugins
# 
class Mortar::Command::Example < Mortar::Command::Base


  # example:hello 
  #
  # Greets the echotext with a warm, mortar welcome! 
  #
  # Examples:
  #
  #    Get a nice mortar greeting.
  #        $ mortar example:hello 
  def hello
    display "Hello World!"
  end
end

```

You'll notice that there are some pretty verbose comments above the class and each of it's methods. The Mortar Development Framework uses these comments to populate the help messages for the command. The comments at the top of the class are used in the overall `mortar help` command. Where as the comments above each method are used in the `mortar example help` command.

#### Command options and arguments ####

Just like the help text, Mortar Development Framework uses comments to define various options and arguments. Simply add the short flag, the long flag, and its description under the specific command description. The options are automatically dumped into an `options` hash. Arguments are given by calling the `shift_argument` method. Here's an example:

```ruby
require "mortar/command/base"

# An example command used for demoing mortar plugins
# 
class Mortar::Command::Example < Mortar::Command::Base


  # example:hello NAME
  #
  # Greets the echotext with a warm, mortar welcome! 
  #
  # -l, --with-love # Add some love to the message 
  # -f, --param-file PARAMFILE  # An example parameter with arguments
  #
  # Examples:
  #
  #    Get a nice mortar greeting.
  #        $ mortar example:hello 
  def hello
    name = shift_argument
    unless name
      error("Usage: mortar example:hello NAME\nMust specify NAME.")
    end

    message = "Hello #{name}!" 

    if options[:with_love]
      message += " <3!"
    end

    display message
  end
end

```

### Extending the Mortar Development Framework ###

All plugins have full access to the methods in the Mortar Development Framework. These methods aren't gaurenteed to stay the same over time though. So make sure you write tests and run them frequently. You can take a look at the [Mortar Development Framework Source Code](https://github.com/mortardata/mortar) to get a better sense of what methods are available to you. A good place to start would be [helpers.rb](https://github.com/mortardata/mortar/blob/master/lib/mortar/helpers.rb)


### Convenience Rake File ###

This example plugin comes with a convenience rake file that will help you develop. Since the Mortar Development Framework looks for plugins exclusively in the `~/.mortar/plugins` directory, every time you make a change you'll need to copy your code to that directory. To solve this problem, we've written a Rakefile that will watch your codebase for changes and rsync your code to that directory. Here is a list of the rake tasks:

* `$ rake watch`    - Watch the code base, and install on change
* `$ rake verify`   - Verify that dependecies are installed in the sandboxed environment
* `$ rake install`  - Install the plugin
* `$ rake clean`    - Remove the plugin
