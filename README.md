Variáveis monitoradas:

Débito cardíaco
Frequência cardíaca --> Volume sistólico * Frequência cardíaca
Fração de ejeção
Aporte cardíaco --> Frequência cardíaca * Fração de ejeção
Volume sistólico
Resistência Periférica

Agentes:

Modelo de Felipe: 

Agentes:
    Coração(Frequência cardíaca, Volume sistólico)
    agent_step!()
    
        #A cada step, calcula-se o débito cardíaco
        #O tecido recebe o débito cardíaco
    
    end

    Tecido Vascular(Resistência Vascular Periférica, Pressão Arterial)
    agent_step!()
        #Recebe do coração o débito cardíaco(sangue)
        #A pressão é recalculada --> Proporcional ao volume e inversamente proporcional a resistência vascular periférica
    end
    Modelo(Drogas inotrópicas, Drogas vasoativas)
        model_step!()
        
        #O volume sistólico aumenta ou diminui -> Drogas inotrópicas
        #A resistência vascular periférica -> Drogas vasoativas
        #Em caso de hemorragia
        #

        end
