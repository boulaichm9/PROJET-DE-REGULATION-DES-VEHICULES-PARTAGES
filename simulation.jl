# src/simulation.jl

using ConcurrentSim
using ResumableFunctions
using Distributions

# ==============================================================================
# PROCESSUS USAGER (CLIENT)
# ==============================================================================
@resumable function usager(env::Environment, origine::Int, destination::Int, 
                           t_velo::Matrix{Float64}, stations::Vector{Container}, 
                           metrics::Dict)
    # 1. L'usager tente de prendre un vélo à la station d'origine
    if stations[origine].level > 0
        @yield get(stations[origine], 1)
        
        # Le vélo est pris, on simule le temps de trajet
        duree = t_velo[origine, destination]
        @yield timeout(env, duree)
        
        # 2. Arrivée à destination : tentative de dépôt
        if stations[destination].level < stations[destination].capacity
            @yield put(stations[destination], 1)
            
            # Succès total : on incrémente le compteur de satisfaction
            metrics[:k] += 1
        else
            # La station est pleine, le vélo est "perdu" ou va ailleurs (simplification)
            # Vous pouvez ajouter une logique de recherche de station voisine ici
        end
    else
        # Échec : pas de vélo disponible au départ
        metrics[:echecs] += 1
    end
end

# ==============================================================================
# PROCESSUS GÉNÉRATEUR D'USAGERS (POISSON)
# ==============================================================================
@resumable function generateur_usagers(env::Environment, lambda::Matrix{Float64}, 
                                       t_velo::Matrix{Float64}, stations::Vector{Container}, 
                                       metrics::Dict)
    S = size(lambda, 1)
    
    # Taux d'arrivée global (somme de tous les lambda_ij)
    taux_global = sum(lambda)
    dist_inter_arrivee = Exponential(1.0 / taux_global)
    
    # Probabilités de choisir un couple (origine, destination)
    poids = vec(lambda) ./ taux_global
    couples = [(i, j) for j in 1:S for i in 1:S]

    while true
        # Attente jusqu'au prochain client
        dt = rand(dist_inter_arrivee)
        @yield timeout(env, dt)
        
        # Tirage de l'origine et destination selon la matrice lambda
        idx = rand(Categorical(poids))
        origine, destination = couples[idx]
        
        if origine != destination
            # Lancement du processus usager
            @process usager(env, origine, destination, t_velo, stations, metrics)
        end
    end
end

# ==============================================================================
# PROCESSUS CAMION (RÉGULATEUR)
# ==============================================================================
@resumable function camion_regulateur(env::Environment, K::Int, x::Float64, 
                                      t_camion::Matrix{Float64}, stations::Vector{Container})
    S = length(stations)
    vélos_embarqués = 0
    position_actuelle = 1 # Le camion commence à la station 1

    while true
        station_cible = position_actuelle # Par défaut
        urgence_max = -Inf
        
        # 1. Calcul du score d'urgence pour chaque station j
        # Cible (x) : taux de remplissage idéal (ex: 0.5 pour 50%)
        for j in 1:S
            if j != position_actuelle
                remplissage_actuel = stations[j].level / stations[j].capacity
                deficit = x - remplissage_actuel
                
                # Exemple de score simple : ratio déficit / temps de trajet
                # (À adapter selon la politique exacte de votre article)
                score = deficit / (t_camion[position_actuelle, j] + 1e-5)
                
                if abs(score) > urgence_max
                    urgence_max = abs(score)
                    station_cible = j
                end
            end
        end
        
        # 2. Déplacement vers la station cible
        duree_trajet = t_camion[position_actuelle, station_cible]
        @yield timeout(env, duree_trajet)
        position_actuelle = station_cible
        
        # 3. Action à la station (Chargement ou Déchargement)
        cap = stations[position_actuelle].capacity
        stock = stations[position_actuelle].level
        objectif_stock = round(Int, cap * x)
        
        diff = stock - objectif_stock
        
        if diff > 0 && vélos_embarqués < K
            # La station a trop de vélos -> Le camion CHarge
            a_prendre = min(diff, K - vélos_embarqués)
            @yield get(stations[position_actuelle], a_prendre)
            vélos_embarqués += a_prendre
            
        elseif diff < 0 && vélos_embarqués > 0
            # La station manque de vélos -> Le camion DÉcharge
            a_deposer = min(abs(diff), vélos_embarqués, cap - stock)
            @yield put(stations[position_actuelle], a_deposer)
            vélos_embarqués -= a_deposer
        end
        
        # Pause minimale pour éviter les boucles infinies si le système est parfait
        @yield timeout(env, 1.0)
    end
end

# ==============================================================================
# PROCESSUS MONITEUR (Enregistrement des données)
# ==============================================================================
@resumable function moniteur(env::Environment, dt::Float64, metrics::Dict)
    while true
        push!(metrics[:liste_t], now(env))
        push!(metrics[:liste_k], metrics[:k])
        @yield timeout(env, dt)
    end
end

# ==============================================================================
# FONCTION PRINCIPALE DE LANCEMENT
# ==============================================================================
function run_simulation(S::Int, N::Int, K::Int, x::Float64, 
                        lambda::Matrix{Float64}, sigma::Vector{Int}, 
                        t_velo::Matrix{Float64}, t_camion::Matrix{Float64}, 
                        sim_time::Float64)
    
    # Initialisation de l'environnement
    env = Simulation()
    
    # Création des stations avec une capacité sigma et un remplissage initial
    # (Par défaut, on répartit les N vélos équitablement)
    velos_par_station = floor(Int, N / S)
    stations = [Container(env, sigma[i], initial=min(velos_par_station, sigma[i])) for i in 1:S]
    
    # Initialisation des métriques
    metrics = Dict(
        :k => 0, 
        :echecs => 0,
        :liste_t => Float64[], 
        :liste_k => Float64[]
    )
    
    # Lancement des processus
    @process generateur_usagers(env, lambda, t_velo, stations, metrics)
    @process camion_regulateur(env, K, x, t_camion, stations)
    
    # On enregistre l'état toutes les 10 unités de temps
    @process moniteur(env, 10.0, metrics) 
    
    # Exécution
    run(env, sim_time)
    
    return metrics
end