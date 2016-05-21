# Mix Master ON FIRE: Getting Started

Welcome to Mix Master! We'll create an app where we keep track of songs, artists, and playlists. Maybe we'll even add in some user ownership. Who knows! It will be an adventure. This is similar to a [tutorial](https://github.com/turingschool/lesson_plans/tree/master/ruby_02-web_applications_with_ruby/mix_master) written for Ruby on Rails, but we are porting it to the Firebird.

### Goals

The original goals of the project were:

* deploy an app to Heroku
* write model tests using RSpec
* write feature tests using RSpec and Capybara
* use branches and commits to develop git workflow
* model one-to-many data relationships
* model many-to-many data relationships
* use factories to create objects to use in tests

Depending on if/when the rest of the tutorial gets written, you may also know/be able to:

* use partials and helpers to tidy up views
* model one-to-one data relationships
* use polymorphic associations to associate an object with one of several other models
* implement authentication using Spotify OAuth
* write controller and view specs

### Getting Started

You will have to have Elixir and Phoenix installed on your machine. Assuming you are a Homebrewer, this will entail:

```
$ brew install elixir
$ mix local.hexdocs
$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez
```
If those commands do not work or you have some other development environment, I cannot help you... but the docs for both [Elixir](http://elixir-lang.org/install.html) and [Phoenix](http://www.phoenixframework.org/docs/installation) are legit.

This tutorial is written using Phoenix v1.1.4, I know v1.2.0 introduced some new changes, but we'll figure those out at some point. If you want to check your Phoenix version:

```
$ mix phoenix.new -v
Phoenix v1.1.4
```

Create that new Phoenix project:

```
$ mix phoenix.new mix_master
```

You will notice that unlike Rails, Phoenix does not have it's own build tool; it uses mix, the Elixir build tool.  When prompted to install dependencies:
```
Fetch and install dependencies? [Yn]
```
say `Y`.

We are going to use the defaults shipped with Phoenix, ExUnit for testing, Ecto with a PostgreSQL for databasing, and Cowboy as the HTTP server.

### Let's run the server!
Yeah, so we haven't written any code, but let's go ahead and see that we don't have any build errors and such.
```
$ cd mix_master
$ mix phoenix.server
```
The first time you run the server you'll see a stream of text as your application is compiled down to Erlang byte code. Don't be scared! Once this is done, you'll see something like this:
```
[info] Running MixMaster.Endpoint with Cowboy using http on port 4000
20 May 09:30:24 - info: compiled 5 files into 2 files, copied 3 in 1.1 sec
```
and if you navigate to [http://localhost:4000/](http://localhost:4000/)
you'll find the fun default page!
![default image](default_page.png)

Ok we now have something to work with. To get out of the server, you'll have to tap `ctrl-c` twice.

### Git Setup

Let's use that version control! Initialize your project as a Git repository:
```
$ git init
```
There will be a bunch of new files added, you can see them with
```
$ git status
```
Then add and commit:

```
$ git add .
$ git commit -m 'initial commit'
```

### Shipping to Heroku

We want to host our Phoenix application on the internet using the popular [Heroku](https://www.heroku.com/) service.

If you don’t already have one, you’ll need to create a [Heroku account](https://signup.heroku.com/www-header). After creating your account download and install the [Heroku Toolbelt](https://toolbelt.heroku.com/).

Now, let's begin shipping to Heroku! Heroku does not automatically have builds for Phoenix apps, so we need to do some configuration.

```
$ heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
Creating app... done, ⬢ cryptic-reef-61126
Setting buildpack to https://github.com/HashNuke/heroku-buildpack-elixir.git... done
https://cryptic-reef-61126.herokuapp.com/ | https://git.heroku.com/cryptic-reef-61126.git
Git remote heroku added
```

The toolbelt will ask for your username and password the first time you run the create, but after that you’ll be using an SSH key for authentication.

After running the create command, you’ll get back the URL where the app is accessible. Try loading the URL in your browser and you’ll see the generic Heroku splash screen. This is because we haven't actually pushed our code to Heroku. All we did was create the remote.

We also have to compile static assets:
```
$ heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
Buildpack added. Next release on cryptic-reef-61126 will use:
  1. https://github.com/HashNuke/heroku-buildpack-elixir.git
  2. https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
Run git push heroku master to create a new release using these buildpacks.
```

[I need to add the rest of the details for deploying to Heroku here.]

### On to [Mix Master Part 2: Implementing Artists](/iterations/2_implementing_artists.markdown)
