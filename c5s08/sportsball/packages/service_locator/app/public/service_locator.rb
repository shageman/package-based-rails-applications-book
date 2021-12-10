# typed: true

class ServiceLocator
  include Singleton

  def register_service(name, service)
    @services ||= {}
    @services[name] = service
    puts "Registered service as #{name}"
  end

  def get_service(name)
    @services ||= {}

    raise ServiceNotFoundError, "Service #{name} was never registered" unless @services[name]

    @services[name]
  end
end

