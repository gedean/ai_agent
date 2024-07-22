# In the future, this became a bus to more than one AI provider
module AI
  BASIC_MODEL = ENV.fetch('OPENAI_BASIC_MODEL')
  ADVANCED_MODEL = ENV.fetch('OPENAI_ADVANCED_MODEL')

  def self.embed(input, model: 'text-embedding-3-large')
    response = OpenAI::Client.new.embeddings(parameters: { input:, model: })
    response.dig('data', 0, 'embedding')
  end

  def self.single_prompt(prompt:, model: AI::BASIC_MODEL, response_format: nil)
    parameters = { model:, messages: [{ role: 'user', content: prompt }] }

    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)
    response.dig('choices', 0, 'message', 'content').strip
  end

  def self.vision(prompt:, image_url:, response_format: nil)
    messages = [{ type: :text, text: prompt },
                { type: :image_url, image_url: { url: image_url } }]

    parameters = { model: AI::ADVANCED_MODEL, messages: [{ role: :user, content: messages }] }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)

    response.dig('choices', 0, 'message', 'content').strip
  end

  def self.single_chat(system:, user:, model: AI::BASIC_MODEL, response_format: nil)
    parameters = { model:,
                   messages: [
                     { role: 'system', content: system },
                     { role: 'user', content: user }
                   ] }

    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)
    response.dig('choices', 0, 'message', 'content').strip
  end

  def self.chat(messages, model: AI::BASIC_MODEL, response_format: nil)
    parameters = { model:, messages: }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)
    response.dig('choices', 0, 'message', 'content').strip
  end

  def self.models
    OpenAI::Client.new.models.list
  end
end
