module IntelliAgent::Anthropic
  BASIC_MODEL = 'claude-3-haiku-20240307' # ENV.fetch('Anthropic_BASIC_MODEL')
  ADVANCED_MODEL = 'claude-3-5-sonnet-20240620' # ENV.fetch('Anthropic_ADVANCED_MODEL')

  def self.single_prompt(prompt:, model: :basic, max_tokens: 1000)
    model = select_model(model)

    parameters = { model:, max_tokens:, messages: [{ role: 'user', content: prompt }] }

    response = Anthropic::Client.new.messages(parameters:)
    response.dig('content', 0, 'text').strip
  end

  def self.single_chat(system:, user:, model: :basic, max_tokens: 1000)
    model = select_model(model)

    parameters = { model:, system:, max_tokens:,
                   messages: [ { role: 'user', content: user } ] }

    response = Anthropic::Client.new.messages(parameters:)
    response.dig('content', 0, 'text').strip
  end

  def self.chat(system:, messages:, model: :basic, max_tokens: 1000)
    model = select_model(model)
    
    parameters = { model:, max_tokens:, system:, messages: }

    response = Anthropic::Client.new.messages(parameters:)
    response.dig('content', 0, 'text').strip
  end

  def self.select_model(model)
    case model
    when :basic
      BASIC_MODEL
    when :advanced
      ADVANCED_MODEL
    else
      model
    end
  end  
end
