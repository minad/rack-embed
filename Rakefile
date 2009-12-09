require 'hoe'

namespace('notes') do
  task('todo')      do; system('ack TODO');      end
  task('fixme')     do; system('ack FIXME');     end
  task('hack')      do; system('ack HACK');      end
  task('warning')   do; system('ack WARNING');   end
  task('important') do; system('ack IMPORTANT'); end
end

desc 'Show annotations'
task('notes' => %w(notes:todo notes:fixme notes:hack notes:warning notes:important))

Hoe.spec 'rack-esi' do
  self.version = '0.0.1'
  developer 'Daniel Mendler', 'mail@daniel-mendler.de'
end

