#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
# Genetic Algorithm (GA) idea
# Step 1. Generate a random initial population of itineraries.
# Step 2. Replicate each itinerary with some variation.
# Step 3. Rank the population according to a fitness function.
# Step 4. Reduce the population to a prescribed size,
#  keeping only the best ranking itineraries.
# Step 5. Go to step 2 unless best itinerary meets an exit criterion.

module TravelingSalesman

  class Gene

    attr_accessor :city, :lat, :lon
    # The constructor of Gene
    def initialize(city = nil, lat = 0.0, lon = 0.0)
      @city = city
      @lat = lat
      @lon = lon
    end

    #Create an other object Gene with the same attributes
    def copy
      Gene.new(@city, @lat, @lon)
    end

    # this/self is equal to that gene
    def eql?(gene)
      self == gene
    end

    # Overload the operator == to compare to Gene objects
    def ==(gene)
      gene.class == self.class &&
      @city == gene.city &&
      @lat == gene.lat &&
      @lon == gene.lon
    end

    # to string
    def to_s
      "(#{@lat}, #{@lon})"
    end

  end # Gene


  class Chromosome < Array

    # The constructor of Chromosome
    def initialize(fitness = 0.0, fitness_alg = Fitness.new)
      @fitness = fitness
      @fitness_alg = fitness_alg
    end

    # Replicate the itenerary
    def genes(i = 0, j = size)
      ngenes = []
      if (i > -1 && j <= size && j >= i)
        i.upto(j-1) do |k|
          ngenes << self[k].copy
        end
      end
      ngenes
    end

    # Overload the operator == to compare to Chromosome objects
    def ==(chrom)
      false unless chrom.class == self.class && size == chrom.size
      0.upto(size-1) do |i|
        return false unless self[i] == chrom[i]
      end
      true
    end

    # this/self is equal to that chrom
    def eql?(chrom)
      self == chrom
    end

    # to determine the rank/distance/fitness of the itenerary/chromosome
    def fitness
      if @fitness == 0.0
        @fitness = @fitness_alg.rank(self)
      end
      @fitness
    end

    # to duplicate a Chromosome
    def copy
      c = Chromosome.new(0.0, @fitness_alg)
      genes.each do |gene|
        c << gene #push_back arreglo
      end
      c
    end

  end # Chromosome


  #The Genotype is the merge of Gene<Chromosome<Grid
  class Genotype

    attr_accessor :grid
    #The constructor for Genotype object
    def initialize(pts)
      @genes = Array.new
      for i in 0...pts.length
        pair = pts.shift
        x = pair.shift
        y = pair.shift
        @genes << Gene.new("Node #{i}", x, y)
      end
    end

    #The variation for the replicates
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
    # to known the cost/rank of the chromosome
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

    # to known the distance in the chromosome between genes
    def distance(g0, g1)
      Math::sqrt( ((g1.lat-g0.lat).abs**2) + ((g1.lon-g0.lon).abs**2) )
    end

  end # Fitness

  #The generation of the GA
  class Crossover

    attr_accessor :rate
    #The constructor for the Crossover
    def initialize
      @rate = 0.90
    end

    #def crossover generate the new leaf of the genetic tree
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

    #The constructor for Mutator
    def initialize
      @rate = 0.10
    end

    #def mutate! change the order and the value of the chrom/(part of the path)
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

  #The Population class manage the distribution and the process of the genetic generation for
  #the differents path tha are the approach to the problem of the traveling salesman
  class Population < Array

    attr_accessor :genotype, :crossover, :mutator, :offspring

    #The constructor for Population objects
    def initialize(pts, logger)
      @genotype = Genotype.new(pts)
      @crossover = Crossover.new
      @mutator = Mutator.new
      @logger = logger
    end

    #def prepare prepares the seed for genetic algorithm
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

      @logger.info "Population con #{self.size} habitantes"
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

    private

    def sort!(list = self)
      list.replace list.sort_by { |chrom| chrom.fitness }
    end

    def select_parents
      parents = []
      s = self.size
      r1 = Kernel.rand(s)
      r2 = Kernel.rand(s)
      while r1 == r2
        r2 = Kernel.rand(s)
      end
      parents << self[r1]
      parents << self[r2]
      parents
    end

  end # Population



# DEBUG

  def debug_ruta_optima
    if __FILE__ == $0

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
  end

# DEBUG



  def calcular_ruta_optima(lista_de_mercado)
    logger.info "************************"
    logger.info "*Calculando ruta óptima*"
    logger.info "************************"

    products = lista_de_mercado.products
    logger.info "***Path inicial = #{products.join(" -> """)}"

    puntos = Array.new
    for p in products
      puntos << [p.ubication.x, p.ubication.y]
    end

    logger.info "*** #{puntos.size} coordenadas listas."

    p = Population.new(puntos, logger)
    p.prepare(20, 100, 15)

    logger.info "*** Distancia inicial = #{p.first.fitness}"

    best_so_far = p.first.fitness
    50.times do |gen|
      logger.info "*** Generación #{gen}"
      p.reproduce
      logger.info "*** #{p.first.fitness}"
      if p.first.fitness < best_so_far
        puts "*** Mejor puntaje encontrado: #{p.first.fitness}"
        puts "Ruta = #{p.first.join(" -> ")}"
        best_so_far = p.first.fitness
      end
    end

  end


end
