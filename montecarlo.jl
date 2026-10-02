using Plots
using Measures
using Random

# --- 1. CONFIGURACIÓN DEL PROBLEMA ---
f(x) = 4 / (1 + x^2)
const I_EXACTA = 2 * pi  # 6.283185307179586

# Dominio y Bounding Box
const X_MIN, X_MAX = -1.0, 1.0
const Y_MIN, Y_MAX = 0.0, 4.0
const AREA_CAJA = (X_MAX - X_MIN) * (Y_MAX - Y_MIN)  # 2 * 4 = 8.0

# --- 2. FUNCIONES DE SIMULACIÓN Y VECTORIZACIÓN ---
function montecarlo_hit_or_miss(N)
    # Generar N puntos aleatorios uniformes en la caja
    x_rand = rand(N) .* (X_MAX - X_MIN) .+ X_MIN
    y_rand = rand(N) .* (Y_MAX - Y_MIN) .+ Y_MIN
    
    # Evaluar la condición de acierto (debajo de f(x))
    aciertos_mask = y_rand .<= f.(x_rand)
    num_aciertos = count(aciertos_mask)
    
    # Estimación de la integral
    I_mc = AREA_CAJA * (num_aciertos / N)
    return I_mc, x_rand, y_rand, aciertos_mask
end

# --- 3. ANIMACIÓN DEL PROCESO DE MUESTREO (HIT-OR-MISS) ---
println("=== MÉTODOS NUMÉRICOS: MONTECARLO ===")
println("-> Generando animación de muestreo aleatorio...")

x_fine = range(-1, 1, length=300)
y_real = f.(x_fine)

# Muestras progresivas para el GIF
muestras = [50, 100, 250, 500, 1000, 2500, 5000]

anim = @animate for N in muestras
    Random.seed!(42) # Semilla fija para reproducibilidad visual
    I_mc, x_pts, y_pts, mask = montecarlo_hit_or_miss(N)
    err = abs(I_mc - I_EXACTA)
    
    p = plot(x_fine, y_real, label="f(x) Real", lw=3, color=:blue,
             title="Montecarlo Hit-or-Miss (N = $N)",
             subtitle="Estimación: $(round(I_mc, digits=4)) | Error: $(round(err, digits=4))",
             xlims=(-1.1, 1.1), ylims=(0, 4.2), legend=:topright)
             
    # Puntos Aciertos (verde) y Fallos (rojo)
    scatter!(p, x_pts[mask], y_pts[mask], mc=:green, ms=2, alpha=0.6, label="Aciertos ($(count(mask)))")
    scatter!(p, x_pts[.!mask], y_pts[.!mask], mc=:red, ms=2, alpha=0.4, label="Fallos ($(N - count(mask)))")
end

# Guardar la animación del muestreo
gif(anim, "montecarlo_muestreo.gif", fps=1.5)

# --- 4. ANÁLISIS DE CONVERGENCIA Y ERROR O(N^-1/2) ---
println("-> Calculando curva de convergencia hasta N = 100,000...")

N_range = round.(Int, 10 .^ range(1, 5, length=200)) # N desde 10 hasta 100,000 en escala log
errores = Float64[]
estimaciones = Float64[]

Random.seed!(123)
for N in N_range
    I_mc, _, _, _ = montecarlo_hit_or_miss(N)
    push!(estimaciones, I_mc)
    push!(errores, abs(I_mc - I_EXACTA))
end

# Gráfica de error en escala Log-Log con cota teórica O(1/√N)
cota_teorica = 1.0 ./ sqrt.(N_range)

plt_conv = plot(N_range, errores, xscale=:log10, yscale=:log10,
                 label="Error Montecarlo |I_MC - I_real|", color=:purple, lw=1.5,
                 title="Tasa de Convergencia de Montecarlo",
                 xlabel="Número de Puntos (N)", ylabel="Error Absoluto", legend=:bottomleft)

plot!(plt_conv, N_range, cota_teorica, linestyle=:dash, color=:black, lw=2,
      label="Cota Teórica O(N^{-1/2})")

# Guardar gráficos finales
savefig("montecarlo_convergencia.png")
savefig("montecarlo_convergencia.svg")

println("-> Archivos 'montecarlo_muestreo.gif' y 'montecarlo_convergencia.png' guardados con éxito.")