# Mix Master Part 2: Implementing Artists

Check out a new branch:

```
$ git checkout -b 2_implement-artists
```

Like all good developers, we'll start by writing a feature test (obviously). We'll use a red-green-refactor approach:

*RED*: Write a test for some piece of functionality that your app should have. Obviously, since we haven't implemented any code, the test should fail. That's what we want!

*GREEN*: Use the error messages and failures to drive your development. Implement the smallest possible piece of code to fix the error. Keep repeating this cycle until you get a passing test.

*REFACTOR*: Now is the time to go back and refactor your code. This means cleaning up variable names, method names, duplication, and implementation.  

We'll start with an integration test, which tests functionality that the end user will need. We'll use this feature test to drive out the creation and functionality of certain routes, controllers, models, and views. As we touch those pieces, we may drop down to a lower level (for example, a model test) in order to test edge cases.

Let's start with a user story for creating a artist:

```
As a user
When I visit the artists index
And I click "New artist"
And I fill in the name
And I fill in an image path
And I click "Create Artist"
Then I should see the artist name and image on the page
```

Phoenix comes with a bunch of default tests. Let's create a test: `touch test/features/user_creates_an_artist_spec.rb`
We would like to use something similar to Capybara for Rails. Turns out there's something called [Hound](https://hexdocs.pm/hound/readme.html). Before we get to writing the test, we have to do some setup... mmmm. Hound requires Elixir 1.0.4 or higher. In the terminal you can check with version you have with: `elixir -v`.

Let's add the dependency to our project. In `mix.exs`, add the dependency:
```
{:hound, "~> 1.0", only: :test}
```
We'll run `mix deps` and then there will probably be some warning messages. You may or may not have to run `mix deps.get` and/or `mix deps.compile`, just follow the warning messages that are outputted.

Start Hound in your `test/test_helper.exs` file before the ExUnit.start() line:
```
Application.ensure_all_started(:hound)
ExUnit.start()
```
This was not documented in the Hound docs, but following [this blog post](http://hashnuke.com/2015/06/07/hound-phoenix-framework-integration-testing.html), let's refactor `mix.exs` as well:
```
def application do
  [mod: {MixMaster, []},
   applications: app_list(Mix.env) ]
end

def app_list do
  [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
   :phoenix_ecto, :postgrex]
end

def app_list(:test), do: [:hound | app_list]
def app_list(_),     do: app_list
```

Lastly, let's configure Hound to work with PhantomJS. In config/test.exs let's change server to true:
```
config :mix_master, MixMaster.Endpoint,
  http: [port: 4001],
  server: true
```
and inside `config/config.exs` let's add:
```
# Start Hound using Phantom JS
config :hound, driver: "phantomjs"
```
under the logger configuration. In a terminal window, start your webdriver:
```
phantomjs --wd
```
and now we are ready to write a test. If you want to run a sample test to see that you've gotten Hound working, check [this blog post](http://hashnuke.com/2015/06/07/hound-phoenix-framework-integration-testing.html) out.

Inside of that file, we'll use our user story to flesh out a feature test:

```ruby
require 'rails_helper'

RSpec.feature "User submits a new artist" do
  scenario "they see the page for the individual artist" do
    artist_name       = "Bob Marley"
    artist_image_path = "http://cps-static.rovicorp.com/3/JPG_400/MI0003/146/MI0003146038.jpg"

    visit artists_path
    click_on "New artist"
    fill_in "artist_name", with: artist_name
    fill_in "artist_image_path", with: artist_image_path
    click_on "Create Artist"

    expect(page).to have_content artist_name
    expect(page).to have_css("img[src=\"#{artist_image_path}\"]")
  end
end
```

Let's run the spec and see what happens. From your command line, type `rspec`.

You should see this error:

```
/usr/local/rvm/gems/ruby-2.2.2/gems/activerecord-4.2.5/lib/active_record/connection_adapters/postgresql_adapter.rb:661:in `rescue in connect': FATAL:  database "mix_master_test" does not exist (ActiveRecord::NoDatabaseError)
```

This means that we haven't created our database yet. We need to run `rake db:create`. Now run the test again.

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: visit artists_path

     NameError:
       undefined local variable or method `artists_path' for #<RSpec::ExampleGroups::UserSubmitsANewArtist:0x007f9dccce0330>
     # ./spec/features/user_creates_a_song_spec.rb:8:in `block (2 levels) in <top (required)>'

Finished in 0.00376 seconds (files took 5.88 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/features/user_creates_a_song_spec.rb:4 # User submits a new artist they see the page for the individual artist
```

The first bit tells us that we don't have a `schema.rb`. That's ok; we don't have any migrations yet. Let's use the errors and failures to guide our development. We'll focus in on this line:

```
NameError:
       undefined local variable or method `artists_path' for #<RSpec::ExampleGroups::UserSubmitsANewArtist:0x007f9dccce0330>
```

This tells us that we don't have an artists_path (which will be the index of all artists), so we'll define that in our `config/routes.rb` file:

```ruby
Rails.application.routes.draw do
  resources :artists, only: [:index]
end
```

When we run rake routes, we'll see this output:

```
Prefix Verb URI Pattern        Controller#Action
artists GET  /artists(.:format) artists#index
```

Since the prefix is `artists`, we can append `_path` which will create the link to `'/artists'`. Run the spec again:

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: visit artists_path

     ActionController::RoutingError:
       uninitialized constant ArtistsController
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/conditionalget.rb:25:in `call'
     ...
```

We'll need to create an ArtistsController. We can do this using the [rails generate controller](http://guides.rubyonrails.org/getting_started.html#say-hello-rails) command, but this will give us a whole bunch of files that we a) probably won't use, and b) are untested. Let's create the controller by hand:

`$ touch app/controllers/artists_controller.rb`

And inside of that file, we'll define the controller:

```ruby
class ArtistsController < ApplicationController
end
```

Run the spec again:

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: visit artists_path

     AbstractController::ActionNotFound:
       The action 'index' could not be found for ArtistsController
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

If we look at the output of `rake routes`, we'll see that `artists_path` should be going to the index action:

```
Prefix Verb URI Pattern        Controller#Action
artists GET  /artists(.:format) artists#index
```

We haven't defined the index action, so let's do that inside of the controller:

```
class ArtistsController < ApplicationController
  def index
  end
end
```

Run the spec again:

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: visit artists_path

     ActionView::MissingTemplate:
       Missing template artists/index, application/index with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:
         * "/Users/rwarbelow/Desktop/Coding/Turing/mix_master/app/views"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

Rails is attempting to find `artists/index` inside of our views folder, but it doesn't see it (because we haven't created it. Good job, Rails!). Let's make that:

```
$ mkdir app/views/artists
$ touch app/views/artists/index.html.erb
```

Run the spec again:

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "New artist"

     Capybara::ElementNotFound:
       Unable to find link or button "New artist"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/capybara-2.5.0/lib/capybara/node/finders.rb:43:in `block in find'
     ...
```

It's not seeing a link or button to click for new artist. We'll need to add that in the view:

```erb
<h1>All Artists</h1>

<%= link_to "New artist", new_artist_path %>
```

Run the spec:

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: <%= link_to "New artist", new_artist_path %>

     ActionView::Template::Error:
       undefined local variable or method `new_artist_path' for #<#<Class:0x007fee98ab17e0>:0x007fee98aa1188>
     # ./app/views/artists/index.html.erb:3:in `_app_views_artists_index_html_erb__160270083333517601_70331334416800'
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

We've used the `new_artist_path` helper, but that doesn't exist yet. It should return a path of `'/artists/new'`, so we'll need to add this to our `routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :artists, only: [:index, :new]
end
```

Run `rake routes` to see the new route:

```
Prefix Verb URI Pattern            Controller#Action
artists GET  /artists(.:format)     artists#index
new_artist GET  /artists/new(.:format) artists#new
```

Now that we have the `new_artist_path`, we'll run the spec again. Can you predict what the error will be?

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "New artist"

     AbstractController::ActionNotFound:
       The action 'new' could not be found for ArtistsController
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

Our route specifies that `'/artists/new'` should go to the `new` action in the controller, but we haven't defined that:

```ruby
class ArtistsController < ApplicationController
  def index
  end

  def new
  end
end
```

Let's run the spec again:

```
.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "New artist"

     ActionView::MissingTemplate:
       Missing template artists/new, application/new with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:
         * "/Users/rwarbelow/Desktop/Coding/Turing/mix_master/app/views"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

Again, the test is looking for a view that we dont have: `artists/new`. We'll make that view:

```
$ touch app/views/artists/new.html.erb
```

Run the spec again:

```
.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: fill_in "artist_name", with: artist_name

     Capybara::ElementNotFound:
       Unable to find field "artist_name"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/capybara-2.5.0/lib/capybara/node/finders.rb:43:in `block in find'
     ...
```

`Capybara::ElementNotFound: Unable to find field "artist_name"` means that it's looking for a field to fill in, but there's nothing on this page. We'll need to make a form for this new artist. In the `new.html.erb` view:

```erb
<%= form_for(Artist.new) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>
<% end %>
```

Notice that we only added one field, even though we know the artist will also have an `image_path`. That's because we don't know if this bit of code will work, or if there is something else we need to do before continuing on the form. Let's run the spec:

```
.
F

Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: <%= form_for(Artist.new) do |f| %>

     ActionView::Template::Error:
       uninitialized constant ActionView::CompiledTemplates::Artist
     # ./app/views/artists/new.html.erb:1:in `_app_views_artists_new_html_erb___2323050576229746218_70261753554780'
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
    ...
```

Ah! So we have an uninitialized constant `Artist`. In the form, we said `form_for(Artist.new)`, but Rails does not know what `Artist` is. This means we'll need to create the model since we're planning to store this in the database:

```
$ rails g model Artist name image_path
```

If we don't specify the data type from the command line, then the default will be a string. That sounds ok to me. This command will give us a migration, a model, and a model test.

Go ahead and run the spec again:

```
/Users/rwarbelow/Desktop/Coding/Turing/mix_master/db/schema.rb doesn't exist yet. Run `rake db:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter /Users/rwarbelow/Desktop/Coding/Turing/mix_master/config/application.rb to limit the frameworks that will be loaded.
/usr/local/rvm/gems/ruby-2.2.2/gems/activerecord-4.2.5/lib/active_record/migration.rb:392:in `check_pending!':  (ActiveRecord::PendingMigrationError)

Migrations are pending. To resolve this issue, run:

  bin/rake db:migrate RAILS_ENV=test

  from /usr/local/rvm/gems/ruby-2.2.2/gems/activerecord-4.2.5/lib/active_record/migration.rb:405:in `load_schema_if_pending!'
  ...
```

Now we care about that first message: `/schema.rb doesn't exist yet. Run rake db:migrate to create it, then try again.`

Let's follow this error message and run `rake db:migrate`. This will generate our schema that will then be loaded into our test database when we run our specs. Run them, and you'll see this message:

```
F*

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) Artist add some examples to (or delete) /Users/rwarbelow/Desktop/Coding/Turing/mix_master/spec/models/artist_spec.rb
     # Not yet implemented
     # ./spec/models/artist_spec.rb:4


Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: fill_in "artist_image_path", with: artist_image_path

     Capybara::ElementNotFound:
       Unable to find field "artist_image_path"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/capybara-2.5.0/lib/capybara/node/finders.rb:43:in `block in find'
     ...
```

Here we have a `Pending` spec: inside of our `artist_spec.rb` file (which was generated when we typed `rails g model Artist`), it stubs out the beginning of a spec to be implemented later. That's ok. We'll leave it for now.

We're failing for a different reason now: `Capybara::ElementNotFound: Unable to find field "artist_image_path"`. What does this mean? Well, we're no longer failing on the `fill_in "artist_name"` line. So we'll need to add another field to our form:

```erb
<%= form_for(Artist.new) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :image_path %>
  <%= f.text_field :image_path %>
<% end %>
```

Run the spec again (I'll leave out the pending example):

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "Create Artist"

     Capybara::ElementNotFound:
       Unable to find link or button "Create Artist"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/capybara-2.5.0/lib/capybara/node/finders.rb:43:in `block in find'
     ...
```

Cool. The `image_path` field is working. Now it can't find a link or button to create the artist. Let's add a submit button to our form:

```erb
<%= form_for(Artist.new) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :image_path %>
  <%= f.text_field :image_path %>

  <%= f.submit %>
<% end %>
```

By default, the Rails `form_for` will put text on the submit button that says "Create Artist" since the form is for an `Artist.new`. If this form were for an existing artist, then the default text would be "Update Artist". You can override the default value of the button by doing something like `<%= f.submit "Save this artist!" %>`. We won't worry about overriding the default today.

Run the spec:

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "Create Artist"

     ActionController::RoutingError:
       No route matches [POST] "/artists"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/railties-4.2.5/lib/rails/rack/logger.rb:38:in `call_app'
     ...
```

Great! Our submit button was found, and now it's trying to find the route for `[POST] "/artists"`. When we look at our routes, we see this:

```
    Prefix Verb URI Pattern            Controller#Action
   artists GET  /artists(.:format)     artists#index
new_artist GET  /artists/new(.:format) artists#new
```

Do you see a `POST` for `'/artists'`? Because I don't. This means we'll need to modify our `routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :artists, only: [:index, :new, :create]
end
```

Now the output of `rake routes` looks like this:

```
    Prefix Verb URI Pattern            Controller#Action
   artists GET  /artists(.:format)     artists#index
           POST /artists(.:format)     artists#create
new_artist GET  /artists/new(.:format) artists#new
```

Ok, now our `POST` to `'/artists'` exists. Run the spec and predict what the error will be before you look below!

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "Create Artist"

     AbstractController::ActionNotFound:
       The action 'create' could not be found for ArtistsController
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

That route is trying to go to the `create` action in our controller. Let's make that:

```ruby
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "Create Artist"

     ActionView::MissingTemplate:
       Missing template artists/create, application/create with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:
         * "/Users/rwarbelow/Desktop/Coding/Turing/mix_master/app/views"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

This tells us that we're missing the template `artists/create`, but we don't really want a template. What we want is to create the artist, then redirect to it's `show` page probably. So in our controller, let's go ahead and implement the creation of this artist:

```ruby
class ArtistsController < ApplicationController
  def index
  end

  def new
  end

  def create
    @artist = Artist.create(artist_params)
    redirect_to @artist
  end

private

  def artist_params
    params.require(:artist).permit(:name, :image_path)  
  end
end
```

The private `artist_params` method is an example of [strong parameters](http://edgeguides.rubyonrails.org/action_controller_overview.html#strong-parameters). We'll pass these permitted params into `Artist.create` in the `def create` method, then redirect to `artist`. This gives us the same behavior as saying `redirect_to artist_path(artist)`.

Run the spec and predict the output:

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: redirect_to artist

     NoMethodError:
       undefined method `artist_url' for #<ArtistsController:0x007fabd7e2fb28>
     # ./app/controllers/artists_controller.rb:10:in `create'
    ...
```

The error, `NoMethodError: undefined method 'artist_url'` indicates that we don't have that route helper yet. Since this is the `show` route, we'll add it to our `routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :artists, only: [:index, :new, :create, :show]
end
```

This produces the following routes:

```
    Prefix Verb URI Pattern            Controller#Action
   artists GET  /artists(.:format)     artists#index
           POST /artists(.:format)     artists#create
new_artist GET  /artists/new(.:format) artists#new
    artist GET  /artists/:id(.:format) artists#show
```

Run the spec:

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "Create Artist"

     AbstractController::ActionNotFound:
       The action 'show' could not be found for ArtistsController
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

Again, we've specified a route but we haven't defined the `show` action in the `ArtistsController`. Go do that:

```ruby
class ArtistsController < ApplicationController
  def index
  end

  def new
  end

  def create
    @artist = Artist.create(artist_params)
    redirect_to @artist
  end

  def show
  end

private

  def artist_params
    params.require(:artist).permit(:name, :image_path)  
  end
end
```

Run the spec:

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: click_on "Create Artist"

     ActionView::MissingTemplate:
       Missing template artists/show, application/show with {:locale=>[:en], :formats=>[:html], :variants=>[], :handlers=>[:erb, :builder, :raw, :ruby, :coffee, :jbuilder]}. Searched in:
         * "/Users/rwarbelow/Desktop/Coding/Turing/mix_master/app/views"
     # /usr/local/rvm/gems/ruby-2.2.2/gems/rack-1.6.4/lib/rack/etag.rb:24:in `call'
     ...
```

Missing template `artists/show` of course. Make it:

```
$ touch app/views/artists/show.html.erb
```

Run the spec:

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: expect(page).to have_content artist_name
       expected to find text "Bob Marley" in ""
     # ./spec/features/user_creates_an_artist_spec.rb:14:in `block (2 levels) in <top (required)>'

Finished in 0.29334 seconds (files took 2.87 seconds to load)
2 examples, 1 failure, 1 pending

Failed examples:

rspec ./spec/features/user_creates_an_artist_spec.rb:4 # User submits a new artist they see the page for the individual artist
```

YAY! A true failure. RSpec cannot find the text "Bob Marley" on that page. That's good, because we don't have anything on the page yet.

We could hardcode "Bob Marley" right onto the view, but we know this is not the implementation that we'll ultimately want, so let's think of other things we could do.

What we want to happen is that we have some artist object that we can call `#name` on. I suppose we could do `Artist.first.name`, but that will only ever allow us to see the first artist on the page. Instead, let's prepare an instance variable in the controller, then access it in the view. How will we grab the correct artist? Well, let's put a `byebug` in the `show` method:

```ruby
  def show
    byebug
  end
```

Now when you run your tests, you should see it stop on the `byebug`:

```
[10, 19] in /Users/rwarbelow/mix_master/app/controllers/artists_controller.rb
   10:     redirect_to artist
   11:   end
   12:
   13:   def show
   14:     byebug
=> 15:   end
   16:
   17: private
   18:
   19:   def artist_params
```

Type `request.path` and you'll see that it returns something like `"/artists/5"` (your id number may be different). We can grab this id out of the URL using our params. `params` returns `{"controller"=>"artists", "action"=>"show", "id"=>"5"}`, so `params[:id]` should return `5`. We can then use this to access the correct artist: `Artist.find(params[:id])`. Try it!

Let's add that code to our controller:

```ruby
  def show
    @artist = Artist.find(params[:id])
  end
```

Nice. But the spec failure is going to say the same thing since we haven't done anything to use that variable. Go back to your view, and add:

```erb
<h1><%= @artist.name %></h1>
```

Run the spec:

```
Failures:

  1) User submits a new artist they see the page for the individual artist
     Failure/Error: expect(page).to have_css("img[src=\"#{artist_image_path}\"]")
       expected to find css "img[src=\"http://cps-static.rovicorp.com/3/JPG_400/MI0003/146/MI0003146038.jpg\"]" but there were no matches
     # ./spec/features/user_creates_an_artist_spec.rb:15:in `block (2 levels) in <top (required)>'

Finished in 0.26541 seconds (files took 3.01 seconds to load)
2 examples, 1 failure, 1 pending

Failed examples:

rspec ./spec/features/user_creates_an_artist_spec.rb:4 # User submits a new artist they see the page for the individual artist
```

Now the test sees "Bob Marley", but we don't see the image source in the html. Let's add an image tag in the `show` view:

```erb
<h1><%= @artist.name %></h1>
<%= image_tag @artist.image_path %>
```

Run the spec, and you'll see that our first feature is passing! (Ignore the pending example)

```
Finished in 0.23294 seconds (files took 2.66 seconds to load)
2 examples, 0 failures, 1 pending
```

Now that we're *green*, let's do a bit of refactoring. First, in our `new.html.erb` view, let's not make an object directly in the view. Instead, let's use an instance variable:

```
<%= form_for(@artist) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :image_path %>
  <%= f.text_field :image_path %>

  <%= f.submit %>
<% end %>
```

And then we can define that instance variable in our controller:

```
  def new
    @artist = Artist.new
  end
```

This will allow us to use this `form_for` code snippet in a partial for the edit view later on in addition to allowing us to do some neat things with error messages on the `@artist` object.

#### Sad Path

What should happen if a user forgets to put in a name? Should an artist be created still? In this case, probably not. Sometimes you'll choose to test your sad path cases at the feature level, and sometimes you will test those validations at the model level. How do you decide? Well, if you care about the error that the user should see, then we probably want to make a feature test. Feature tests are expensive and slow, so if we're going to test a sad path, we only need one. The rest of our validations will be tested at the model level. Let's go.

Here's our sad path user story:

```
As a user
When I visit the artists index
And I click "New artist"
And I fill in an image path
And I click "Create Artist"
Then I should see "Name cannot be blank" on the page
```

Let's add a new context to our existing spec file:

```ruby
require 'rails_helper'

RSpec.feature "User submits a new artist" do
  scenario "they see the page for the individual artist" do
    artist_name       = "Bob Marley"
    artist_image_path = "http://cps-static.rovicorp.com/3/JPG_400/MI0003/146/MI0003146038.jpg"

    visit artists_path
    click_on "New artist"
    fill_in "artist_name", with: artist_name
    fill_in "artist_image_path", with: artist_image_path
    click_on "Create Artist"

    expect(page).to have_content artist_name
    expect(page).to have_css("img[src=\"#{artist_image_path}\"]")
  end

  context "the submitted data is invalid" do
    scenario "they see an error message" do
      artist_image_path = "http://cps-static.rovicorp.com/3/JPG_400/MI0003/146/MI0003146038.jpg"

      visit artists_path
      click_on "New artist"
      fill_in "artist_image_path", with: artist_image_path
      click_on "Create Artist"

      expect(page).to have_content "Name can't be blank"
    end
  end
end
```

Notice that we wrap this `scenario` in a `context` block. Context blocks can be used to add additional information that makes it easier to read what the test should be doing.

Let's run the spec:

```
Failures:

  1) User submits a new artist the submitted data is invalid they see an error message
     Failure/Error: expect(page).to have_content "Name can't be blank"
       expected to find text "Name can't be blank" in ""
     # ./spec/features/user_creates_an_artist_spec.rb:27:in `block (3 levels) in <top (required)>'

Finished in 0.48679 seconds (files took 4.44 seconds to load)
3 examples, 1 failure, 1 pending

Failed examples:

rspec ./spec/features/user_creates_an_artist_spec.rb:19 # User submits a new artist the submitted data is invalid they see an error message
```

So what's happening here? Well, Capybara is looking for the text "Name can't be blank", but it's not seeing *anything* on the page. That's because the only thing that's printing out to the page right now is `@artist.name`. And if we didn't enter a name, then of course nothing is on the page.

If you don't understand that, I'd suggest using a `save_and_open_page` in your test to see what Capybara is seeing. Perhaps you can also put a `byebug` in the controller after the instance variable `@artist` is assigned.

This means that the artist is being created regardless of the fact that a name was not submitted. Let's pause on the feature test for a moment and drop down to the model level in order to validate the presence of a name. Add the word `pending` right below `scenario "they see an error message" do`.

#### Validations at the Model Level

We can use the [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) gem in order to test validations easily with one line. First, add the gem to your Gemfile:

```ruby
group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers'
end
```

Note: You may need to add `gem 'shoulda-matchers', github: 'thoughtbot/shoulda-matchers'` per [this bug report](https://github.com/thoughtbot/shoulda-matchers/issues/703) if you get a `NoMethodError` when trying to run rspec after bundling.

And `bundle`. Next, we'll configure shoulda matchers to work with RSpec in `rails_helper.rb`:

```ruby
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

...etc...
```


Now let's add some model-level validation tests in `artist_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Artist, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:image_path) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
```

Even though we don't have a feature test to drive out these validations, we know that the `create artist` feature should act the same way (ie - show an error message) if any of these things are wrong. Run `rpsec` and let's see what happens.

```
Failures:

  1) Artist should require name to be set
     Failure/Error: it { is_expected.to validate_presence_of(:name) }

       Expected errors to include "can't be blank" when name is set to nil,
       got no errors
     # ./spec/models/artist_spec.rb:5:in `block (2 levels) in <top (required)>'

  2) Artist should require image_path to be set
     Failure/Error: it { is_expected.to validate_presence_of(:image_path) }

       Expected errors to include "can't be blank" when image_path is set to nil,
       got no errors
     # ./spec/models/artist_spec.rb:6:in `block (2 levels) in <top (required)>'

  3) Artist should require case sensitive unique value for name
     Failure/Error: it { is_expected.to validate_uniqueness_of(:name) }

       Expected errors to include "has already been taken" when name is set to "a",
       got no errors
     # ./spec/models/artist_spec.rb:7:in `block (2 levels) in <top (required)>'

Finished in 0.94621 seconds (files took 4.57 seconds to load)
5 examples, 3 failures, 1 pending

Failed examples:

rspec ./spec/models/artist_spec.rb:5 # Artist should require name to be set
rspec ./spec/models/artist_spec.rb:6 # Artist should require image_path to be set
rspec ./spec/models/artist_spec.rb:7 # Artist should require case sensitive unique value for name
```

Lot's of failures. Let's focus on that first one. RSpec is looking for errors when a name is nil. We don't have a validation for this in our model, so let's go add that in `artist.rb`:

```ruby
class Artist < ActiveRecord::Base
  validates :name, presence: true
end
```

When we run the specs again, we see that spec passes now. To make the other two pass, we add similar validations:

```ruby
class Artist < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :image_path, presence: true
end
```

If you haven't already, you should probably read about [other things you can validate using ActiveRecord](http://guides.rubyonrails.org/active_record_validations.html).

All of our model specs are now passing, so let's go back up to the feature test level and remove `pending`. This spec will still fail since we're not handling what happens if a artist is not successfully saved into the database. So let's modify our controller `create` action:

```ruby
  def create
    @artist = Artist.new(artist_params)
    if @artist.save
      redirect_to @artist
    else
      render :new
    end
  end
```

Now whenever the artist cannot successfully be saved due to failing validations, it will render the `new` view. We'll need to add a bit of code in `new.html.erb` in order to check whether or not errors exist on the `@artist` object:

```erb
<%= form_for(@artist) do |f| %>
  <% if @artist.errors.any? %>
    <h2><%= pluralize(@artist.errors.count, "error") %> prohibited this record from being saved:</h2>
    <ul>
      <% @artist.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  <% end %>

  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.label :image_path %>
  <%= f.text_field :image_path %>

  <%= f.submit %>
<% end %>
```

#### Your turn

Write and implement a feature test for viewing all artists (`spec/features/user_views_all_artists_spec.rb`):

```
As a user
Given that artists exist in the database
When I visit the artists index
Then I should see each artist's name
And each name should link to that artist's individual page
```

Write and implement a feature test for editing an artist (`spec/features/user_edits_an_artist_spec.rb`):

```
As a user
Given that an artist exists in the database
When I visit that artist's show page
And I click on "Edit"
And I fill in a new name
And I click on "Update Artist"
Then I should see the artist's updated name
Then I should see the existing image
```

Write and implement a feature test for deleting an artist (`spec/features/user_deletes_an_artist_spec.rb`):

```
As a user
Given that an artist exists in the database
When I visit that artist's show page
And I click on "Delete"
Then I should be back on the artist index page
Then I should not see the artist's name
```

All tests should be passing. Go ahead and add and commit your work to this branch. Before you commit, read [this post](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) to learn about proper commit messages and conventional format. Check out master, and merge the branch back into master. Push to Heroku, and migrate on Heroku.

```
$ git add .
$ git commit
$ git checkout master
$ git merge 2_implement-artists
$ git push heroku master
$ heroku run rake db:migrate
```

Now you can visit `https://your-herokuapp-number.herokuapp.com/artists` and test out this functionality! Show your mom!!

### Life Raft

If you've messed things up, you can clone down the [2_implement-artists branch](https://github.com/rwarbelow/mix_master/tree/2_implement-artists) of `mix_master` which is complete up to this point in the tutorial.

### On to [Mix Master Part 3: Implementing Songs](/ruby_02-web_applications_with_ruby/mix_master/3_implementing_songs.markdown)
