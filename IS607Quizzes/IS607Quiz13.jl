# IS607 Week 13 Quiz
# Paul Garaud


# matrix multiplication (vcov)
srand(100)

function test()
    x = Array(Float64, 100, 100)
    x = rand(100, 100)
    x * x'
end

gc()

@time test()
# ~ .36 sec execution time
