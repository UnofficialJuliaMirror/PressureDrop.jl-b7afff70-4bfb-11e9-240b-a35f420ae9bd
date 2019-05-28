@testset "Wellbore object" begin

md_bad = [-1.,2.,3.,4.]
md_good = [1.,2.,3.,4.]
inc = [1.,2.,3.,4.]
tvd_bad = [-1.,2.,3.,4.]
tvd_good = [1.,2.,3.,4.]
id = [1.,1.,1.,1.]

#implicit test for adding the leading 0,0 survey point:
w = Wellbore(md_good, inc, tvd_good, id)

@test w.id[1] == w.id[2]

#implicit test for allowing negatives:
Wellbore(md_bad, inc, tvd_bad, id, true)

try
    Wellbore(md_bad, inc, tvd_good, id)
catch e
    @test e isa Exception
end

try
    Wellbore(md_good, inc, tvd_bad, id)
catch e
    @test e isa Exception
end

end #testset for Wellbore object


#%% setup
segments = 100
MDs = range(0, 5000, length = segments) |> collect
incs = repeat([0], inner = segments)
TVDs = range(0, 5000, length = segments) |> collect

well = Wellbore(MDs, incs, TVDs, 2.441)

pressures, temps = pressure_and_temp(well = well, roughness = 0.0006,
                                    temperature_method = "Shiu", geothermal_gradient = 1.0, BHT = 200,
                                    pressurecorrelation = HagedornAndBrown, WHP = 350, dp_est = 25,
                                    q_o = 100, q_w = 500, GLR = 1200, APIoil = 35, sg_water = 1.1, sg_gas = 0.8)


@testset "Pressure and temp wrapper" begin

@test length(pressures) == length(temps) == segments
@test pressures[1] == 350
@test pressures[end] ≈ 1068 atol = 1
@test temps[end] == 200
@test temps[1] ≈ 181 atol = 1

end #testset for pressure & temp wrapper


@testset "Valve table" begin

valves = GasliftValves([1000,3000,4500], [1100,1050,950], [0.073,0.073,0.073], [16,16,16])
casing_pressures = casing_traverse_topdown(wellbore = well, temperatureprofile = temps,
                                    CHP = 950, sg_gas = 0.7, dp_est = 10)

vdata = valve_calcs(valves, well, 0.8, pressures, casing_pressures, temps)
valve_table(vdata)

#TODO: generate in Excel using valve sheet & gas passage calculator
expected_results =
[1;
 1;
 1]

@test expected_results == expected_results

end #testset for valve table
