module HeartSimulation

using Agents
using Random
using Graphs

mutable struct Heart <: AbstractAgent
    id::Int
    pos::Tuple{Int, Int}  
    state::Symbol 
    contractile_force::Float64
    cycle_time::Int
end

mutable struct BloodVessel <: AbstractAgent
    id::Int
    pos::Tuple{Int, Int} 
    pressure::Float64
    elasticity::Float64
    resistance::Float64
end


const SYSTOLIC_TARGET = 120.0
const DIASTOLIC_TARGET = 80.0
const HEART_RATE = 60
const TIME_STEPS_PER_BEAT = 60


function initialize_heart_model()

    space = GridSpace((1, 1))
    
    properties = Dict(
        :vessel => nothing 
    )
    
    model = AgentBasedModel(
        Union{Heart, BloodVessel},
        space;
        properties = properties
    )
    

    heart = Heart(nextid(model), (1, 1), :relaxing, 1.0, 0)
    add_agent_pos!(heart, model)

    vessel = BloodVessel(nextid(model), (1, 1), DIASTOLIC_TARGET, 0.8, 0.1)
    add_agent_pos!(vessel, model)
    model.properties[:vessel] = vessel
    
    return model
end

function heart_step!(heart::Heart, model)

    heart.cycle_time += 1
    
    if heart.cycle_time >= TIME_STEPS_PER_BEAT
        heart.cycle_time = 0
        heart.state = heart.state == :contracting ? :relaxing : :contracting
    end
    

    if heart.state == :contracting

        heart.contractile_force = sin(π * heart.cycle_time / TIME_STEPS_PER_BEAT)
    else

        heart.contractile_force = 0.2 * sin(π * heart.cycle_time / TIME_STEPS_PER_BEAT)
    end
    

    vessel = model.properties[:vessel]
    if heart.state == :contracting

        pressure_range = SYSTOLIC_TARGET - DIASTOLIC_TARGET
        target_pressure = DIASTOLIC_TARGET + (pressure_range * heart.contractile_force)
    else

        pressure_above_diastolic = vessel.pressure - DIASTOLIC_TARGET
        target_pressure = DIASTOLIC_TARGET + (pressure_above_diastolic * vessel.elasticity)
    end
    
    vessel.pressure += (target_pressure - vessel.pressure) * (1 - vessel.resistance)
end


function model_step!(model)
    for agent in allagents(model)
        if agent isa Heart
            heart_step!(agent, model)
        end
    end
end

function run_heart_simulation(steps=300)
    model = initialize_heart_model()
    pressures = Float64[]
    
    for _ in 1:steps
        model_step!(model)
        vessel = model.properties[:vessel]
        push!(pressures, vessel.pressure)
    end
    
	print(pressures)

    return pressures
end

export Heart, BloodVessel, initialize_heart_model, heart_step!, model_step!, run_heart_simulation

end

run_heart_simulation()

