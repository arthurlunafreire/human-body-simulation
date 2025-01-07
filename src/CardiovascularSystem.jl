using Agents
using Random
using Statistics

@agent struct Heart(NoSpaceAgent)
	contractility::Float64 
	rate::Float64   
	current_phase::Symbol
	phase_timer::Float64
end

@agent struct Tissue(NoSpaceAgent)
	resistance::Float64
	compliance::Float64
	current_pressure::Float64
	blood_volume::Float64
end

function initialize_cardio_model(;
	n_tissues = 10,
	target_systolic = 120,
	target_diastolic = 80,
	base_heart_rate = 75
)
	properties = Dict(
    	:target_systolic => target_systolic,
    	:target_diastolic => target_diastolic,
    	:system_pressure => target_diastolic,
    	:total_blood_volume => 5000.0,  
    	:cardiac_output => 0.0,     	
    	:mean_pressure => 0.0
	)
    
	model = ABM(Union{Heart, Tissue}; properties)
    

	heart = Heart(
        11,
    	0.7,          
    	base_heart_rate,
    	:diastole,
    	0.0
	)
	add_agent!(heart, model)
    
	
	for i in 1:n_tissues
    	
    	resistance = 0.8 + rand() * 0.4	
    	compliance = 0.6 + rand() * 0.8	
   	 
    	tissue = Tissue(
            i,
        	resistance,
        	compliance,
        	properties[:target_diastolic],
        	properties[:total_blood_volume] / n_tissues
    	)
    	add_agent!(tissue, model)
	end
    
	return model
end

function model_step!(model)
	update_system_pressure!(model)
	calculate_cardiac_output!(model)
end

function agent_step!(agent::Heart, model)

	cycle_duration = 60.0 / agent.rate
	systole_duration = 0.3
    
	agent.phase_timer += 1/60
    
	if agent.current_phase == :systole
    	if agent.phase_timer >= systole_duration
        	agent.current_phase = :diastole
        	agent.phase_timer = 0.0
    	end
	else
    	if agent.phase_timer >= (cycle_duration - systole_duration)
        	agent.current_phase = :systole
        	agent.phase_timer = 0.0
    	end
	end
    
	if agent.current_phase == :systole
    	target = model.target_systolic * agent.contractility
	else
    	target = model.target_diastolic
	end
    
	model.system_pressure = target
end

function agent_step!(agent::Tissue, model)

	pressure_difference = model.system_pressure - agent.current_pressure
	flow = pressure_difference / agent.resistance
    
	agent.current_pressure += flow * agent.compliance
    

	agent.blood_volume += flow
end

function update_system_pressure!(model)

	tissue_pressures = [a.current_pressure for a in allagents(model) if a isa Tissue]
	model.mean_pressure = mean(tissue_pressures)
end

function calculate_cardiac_output!(model)
	heart = getindex(model, 11)
	if heart.current_phase == :systole

    	stroke_volume = 70.0 * heart.contractility  
    	model.cardiac_output = stroke_volume * heart.rate
	end
end

# Analysis functions
function get_pressure_range(model)
	pressures = Float64[]
	for _ in 1:100  
    	step!(model, agent_step!, model_step!)
    	push!(pressures, model.system_pressure)
	end
	return minimum(pressures), maximum(pressures)
end

model = initialize_cardio_model()
min_p, max_p = get_pressure_range(model)
println("Pressure range: $min_p / $max_p mmHg")
