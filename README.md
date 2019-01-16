[![Gem Version](https://badge.fury.io/rb/klaxon.svg)](http://badge.fury.io/rb/klaxon)

# klaxson
Insert a programmable interactive warning prompt for developers
before taking dangerous or destructive action.

Example:
```ruby
Klaxon.alert banner: 'Delete', description: 'About to delete files!' do
  system "rm -rf"
end
```

Prints to `STDERR`
```
    _____       _      _
   |  __ \     | |    | |
   | |  | | ___| | ___| |_ ___
   | |  | |/ _ \ |/ _ \ __/ _ \
   | |__| |  __/ |  __/ |_  __/
   |_____/ \___|_|\___|\__\___|


About to delete files!
To continue, press ENTER. To abort, press Ctrl+C...
```

### Using with YAML
The keyword args in the `alert` method work well with YAML symbol keys, and
can be mixed with existing YAML-based build configurations if desired.

Given a config like:
```yaml
---
dev:
    :alert:
        :banner: Development
        :description: |
            You are deploying to the dev environment
            outside the CI pipleine.
        :color: :yellow
prod:
    :alert:
        :banner: Production
        :description: |
            DANGER! You are deploying directly to
            production outside the CI pipeline. This
            is highly unusual and dangerous!
        :color: :red
```

The args for `alert` can be passed like:
```ruby
Klaxon.alert YAML.load_file('config.yml').dig ENV['ENV'], :alert do
   # deploy files...
end
```
