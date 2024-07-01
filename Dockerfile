# Use the official Ruby image
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client \
  curl

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Set an environment variable to avoid some warnings
ENV BUNDLER_VERSION=2.5.14
ENV RUBYOPT='-W:no-deprecated -W:no-experimental'

# Set up the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install the required Ruby gems
RUN gem install bundler:$BUNDLER_VERSION && bundle install

# Copy the rest of the application code
COPY . .

# Install Node.js packages and precompile assets
RUN yarn install --check-files
RUN bundle exec rails assets:precompile

# Expose the port the app runs on
EXPOSE 3005

# Run the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3005"]
