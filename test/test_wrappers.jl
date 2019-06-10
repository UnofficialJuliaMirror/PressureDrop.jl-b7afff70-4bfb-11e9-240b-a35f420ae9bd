@testset "Pressure and temp wrapper" begin

segments = 100
MDs = range(0, 5000, length = segments) |> collect
incs = repeat([0], inner = segments)
TVDs = range(0, 5000, length = segments) |> collect

well = Wellbore(MDs, incs, TVDs, 2.441)

model = WellModel(wellbore = well, roughness = 0.0006,
                    temperature_method = "Shiu", geothermal_gradient = 1.0, BHT = 200,
                    pressurecorrelation = HagedornAndBrown, WHP = 350 - pressure_atmospheric, dp_est = 25,
                    q_o = 100, q_w = 500, GLR = 1200, APIoil = 35, sg_water = 1.1, sg_gas = 0.8)

pressures = pressure_and_temp!(model)
temps = model.temperatureprofile

@test length(pressures) == length(temps) == segments
@test pressures[1] == 350 - pressure_atmospheric
@test pressures[end] ≈ (1068 - pressure_atmospheric) atol = 1
@test temps[end] == 200
@test temps[1] ≈ 181 atol = 1

end #testset for pressure & temp wrapper

#TODO: add a wrapper test that also checks read_valves
