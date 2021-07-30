require 'prime'
require 'etc'
require 'benchmark'

MAX = 10_000_000

def count_prime_numbers(from, to) = (from..to).count {|n| n.prime? }

cores = Etc.nprocessors

Benchmark.bm do |x|
  x.report('seq') { count_prime_numbers(2, MAX) }

  x.report('rac') do
    ractors = []
    cores.times do
      ractors << Ractor.new do
        from = Ractor.receive
        to = Ractor.receive
        count_prime_numbers(from, to)
      end
    end

    batch_size = MAX / cores
    from = 2
    ractors.each do |r|
      to = from + batch_size
      r.send from
      r.send [to, MAX].min
      from = to + 1
    end

    cnt = 0
    cores.times do
      r, obj = Ractor.select(*ractors)
      ractors.delete(r)
      cnt += obj
    end

    # puts cnt
  end
end
