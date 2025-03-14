desc 'Ставим like'
task like: :environment do
  json_path = Rails.root.join('spec', 'fixtures', 'like.json').to_path
  message = JSON.parse(File.read(json_path))
  LikesProducer.send(message) # Если инкапсулировать логику продьюсера, то код не придется переписывать при переходе с кролика на кафку или если через пару лет еще что-то появится
end
