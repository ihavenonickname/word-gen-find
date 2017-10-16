function individual_to_str(individual)
    local word = ""

    for _, byte in ipairs(individual) do
        word = word .. string.char(byte)
    end

    return word
end

function random_letter_ascii()
    return math.random(97, 122)
end

function calc_fitness(individual, target)
    local n_difs = 0

    for i = 1, #target do
        if individual[i] ~= target[i] then
            n_difs = n_difs + 1
        end
    end

    return n_difs / #target
end

function crossover(individual1, individual2)
    local child = {}
    local partition = math.random(#individual1)

    for i = 1, #individual1 do
        if i <= partition then
            child[i] = individual1[i]
        else
            child[i] = individual2[i]
        end
    end

    return child
end

function mutate(individual)
    for i = 1, #individual do
        if math.random() < math.random() then
            individual[i] = random_letter_ascii()
        end
    end
end

function find(target, population_size, max_iterations, mutation_rate)
    math.randomseed(os.time())

    local population = {}

    for i = 1, population_size do
        local individual = {}

        for j = 1, #target do
            individual[j] = random_letter_ascii()
        end

        population[i] = individual
    end

    local n_iterations = 1

    while n_iterations <= max_iterations do
        n_iterations = n_iterations + 1

        local bad_indexes = {}

        for i, individual in ipairs(population) do
            local fitness = calc_fitness(individual, target)

            if fitness == 0 then
                return {
                    success = true,
                    population = population,
                    index = i,
                    iterations = n_iterations
                }
            end

            if math.random() < fitness then
                bad_indexes[#bad_indexes + 1] = i
            end
        end

        for i = #bad_indexes, 1, -1 do
            if #population / population_size < 0.1 then
                break
            end

            local bad_index = bad_indexes[i]

            table.remove(population, bad_index)
        end

        while #population < population_size do
            local individual1 = population[math.random(#population)]
            local individual2 = population[math.random(#population)]

            population[#population + 1] = crossover(individual1, individual2)
        end

        for i = 1, #population do
            if math.random() < mutation_rate then
                mutate(population[i])
            end
        end
    end

    return {
        success = false,
        population = population
    }
end

function main()
    local init = os.clock()
    local result = find({97, 98, 99, 100, 101, 102, 103}, 50, 100000, 0.001)
    local ellapsed = os.clock() - init

    if result.success then
        individual = result.population[result.index]
        print(result.iterations, individual_to_str(individual))
    else
        print("Not found")
    end

    print(ellapsed)
end

main()
