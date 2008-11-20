#!/usr/bin/ruby -w
#genetic.rb

module RubyGa
  
  class Gene
    
    attr_accessor :city, :lat, :lon
    
    def initialize(city = nil, lat = 0.0, lon = 0.0)
      @city = city
      @lat = lat
      @lon = lon
    end

    def copy
      Gene.new(@city, @lat, @lon)
    end

    def eql?(gene)
      self == gene
    end

    def ==(gene)
      gene.class == self.class &&
      @city == gene.city &&
      @lat == gene.lat &&
      @lon == gene.lon
    end

    def to_s
      "(#{@lat}, #{@lon})"
    end

  end # Gene

  class Chromosome < Array

    def initialize(fitness = 0.0, fitness_alg = Fitness.new)
      @fitness = fitness
      @fitness_alg = fitness_alg
    end

    def genes(i = 0, j = size)
      ngenes = []
      if (i > -1 && j <= size && j >= i)
        i.upto(j-1) do |k|
          ngenes << self[k].copy
        end
      end
      ngenes
    end

    def ==(chrom)
      false unless chrom.class == self.class && size == chrom.size
      0.upto(size-1) do |i|
        return false unless self[i] == chrom[i]
      end
      true
    end

    def eql?(chrom)
      self == chrom
    end

    def fitness
      if @fitness == 0.0
        @fitness = @fitness_alg.rank(self)
      end
      @fitness
    end

    def copy
      c = Chromosome.new(0.0, @fitness_alg)
      genes.each do |gene|
        c << gene
      end
      c
    end

  end # Chromosome

  class Grid

    attr_reader :n, :pts, :min

    def initialize(n)
      raise ArgumentError unless Integer === n && n > 1
      @n = n
      @pts = []
      n.times do |i|
        x = i.to_f
        n.times { |j| @pts << [x, j.to_f] }
      end
      # @min is length of any shortest tour traversing the grid.
      @min = n * n
      @min += Math::sqrt(2.0) - 1 if @n & 1 == 1
      puts "Shortest possible tour = #{@min}"
    end

  end # Grid

  class Genotype

    attr_accessor :grid

    def initialize(grid = Grid.new(5))
      @grid = grid
      @genes = Array.new
      pts = @grid.pts
      for i in 0...pts.length
        pair = pts.shift
        x = pair.shift
        y = pair.shift
        @genes << Gene.new("Node #{i}", x, y)
      end
    end

    def new_rand_chrom
      @genes.replace @genes.sort_by { rand }
      c = Chromosome.new
      @genes.each do |gene|
        c << gene.copy
      end
      c
    end

  end # Genotype

  class Fitness

    def rank(chrom)
      fit = distance(chrom.last, chrom.first)
      i = 0
      while i < chrom.length - 1
        g0 = chrom[i]
        g1 = chrom[i+1]
        fit += distance(g0, g1)
        i += 1
      end
      fit
    end

    def distance(g0, g1)
      Math::sqrt( ((g1.lat-g0.lat).abs**2) + ((g1.lon-g0.lon).abs**2) )
    end

  end # Fitness

  class Crossover

    attr_accessor :rate

    def initialize
      @rate = 0.90
    end

    def crossover(p0, p1)
      children = []
      if rand < @rate
        c0, c1 = Chromosome.new, Chromosome.new
        min = [p0.length, p1.length].min
        index = rand(min)
        for i in index...min
          c0 << p0[i].copy
          c1 << p1[i].copy
        end
        children << fill(c0, p1)
        children << fill(c1, p0)
      end
      children
    end

    private

    def fill(c, p)
      p.each do |gene|
        c << gene unless c.include?(gene)
      end
      c
    end

  end # Crossover

  class Mutator

    attr_accessor :rate

    def initialize
      @rate = 0.10
    end

    def mutate!(chrom)
      if rand < @rate
        s = chrom.length - 1
        r1 = rand(s)
        r2 = rand(s)
        while r1 == r2
          r2 = rand(s)
        end
        min = [r1, r2].min
        max = [r1, r2].max
        while max > min
          chrom[min], chrom[max] = chrom[max], chrom[min]
          max -= 1
          min += 1
        end
      end
    end

  end # Mutator

  class Population < Array

    attr_accessor :genotype, :crossover, :mutator, :offspring

    def initialize(genotype = Genotype.new, crossover = Crossover.new,
mutator = Mutator.new)
      @genotype = genotype
      @crossover = crossover
      @mutator = mutator
    end

    def prepare(size = 100, initial_size = 1000, offspring = 80)
      @offspring = offspring
      initial = []
      initial_size.times do
        g = @genotype.new_rand_chrom
        initial << g unless initial.include?(g)
      end
      sort!(initial)
      size.times do
        self << initial.shift
      end
    end

    def reproduce
      (@offspring/2).times do
        parents = select_parents
        children = @crossover.crossover(parents[0], parents[1])
        children.each do |child|
          @mutator.mutate!(child)
          self.pop
          self.unshift(child)
        end
      end
      sort!
    end

    def min
      @genotype.grid.min
    end

    private

    def sort!(list = self)
      list.replace list.sort_by { |chrom| chrom.fitness }
    end

    def select_parents
      parents = []
      s = size
      r1, r2 = rand(s), rand(s)
      while r1 == r2
        r2 = rand(s)
      end
      parents << self[r1]
      parents << self[r2]
      parents
    end

  end # Population

end # RubyGa


if __FILE__ == $0

  include RubyGa

  s = Time.now
  puts "Genetic algorithm started at #{s}"
  p = Population.new
  p.prepare(20, 100, 15)
  best_so_far = p.first.fitness
  gen = 1
  while best_so_far > p.min
    p.reproduce
    if p.first.fitness < best_so_far
      puts "Best fitness found = #{p.first.fitness} at generation #{gen}"
      puts "Path = \n#{p.first.join(" -> ")}"
      puts "#{Time.now-s} seconds into execution"
      puts
      best_so_far = p.first.fitness
    end
    gen += 1
  end

end
