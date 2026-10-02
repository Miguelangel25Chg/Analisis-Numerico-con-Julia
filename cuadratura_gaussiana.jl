using Plots
using Measures

# --- 1. DEFINICIÓN DE LA FUNCIÓN Y VALOR EXACTO ---
f(x) = 4 / (1 + x^2)
const I_EXACTA = 2 * pi  # 6.283185307179586

# Base de Lagrange para calcular los pesos w_i de forma explícita
function lagrange_basis(x, nodes, i)
    L = 1.0
    for j in 1:length(nodes)
        if j != i
            L *= (x - nodes[j]) / (nodes[i] - nodes[j])
        end
    end
    return L
end

# Nodos y Pesos de Gauss-Legendre tabulados para n = 2, 3, 4, 5 en [-1, 1]
# (En un marco avanzado se pueden obtener como autovalores de la matriz Jacobi)
const GAUSS_NODES = Dict(
    2 => [-0.5773502692, 0.5773502692],
    3 => [-0.7745966692, 0.0, 0.7745966692],
    4 => [-0.8611363116, -0.3399810436, 0.3399810436, 0.8611363116],
    5 => [-0.9061798459, -0.5384693101, 0.0, 0.5384693101, 0.9061798459]
)

const GAUSS_WEIGHTS = Dict(
    2 => [1.0, 1.0],
    3 => [0.5555555556, 0.8888888889, 0.5555555556],
    4 => [0.3478548451, 0.6521451549, 0.6521451549, 0.3478548451],
    5 => [0.2369268851, 0.4786286705, 0.5688888889, 0.4786286705, 0.2369268851]
)

# Función de integración por Cuadratura Gaussiana
function gauss_quadrature(f, n)
    nodes = GAUSS_NODES[n]
    weights = GAUSS_WEIGHTS[n]
    return sum(weights .* f.(nodes))
end

# --- 2. EVALUACIÓN Y CONSOLA ---
println("=== RESULTADOS CUADRATURA GAUSSIANA ===")
println("Valor exacto (2π): ", I_EXACTA)
for n in 2:5
    i_gauss = gauss_quadrature(f, n)
    err = abs(i_gauss - I_EXACTA)
    println("n = $n | Integral: $(round(i_gauss, digits=8)) | Error absoluto: $(round(err, sigdigits=3))")
end

# --- 3. ANIMACIÓN Y GUARDADO DE ARCHIVOS ---
x_fine = range(-1, 1, length=300)
y_real = f.(x_fine)

println("\n-> Generando animación GIF para Cuadratura Gaussiana...")

anim = @animate for n in 2:5
    nodos = GAUSS_NODES[n]
    pesos = GAUSS_WEIGHTS[n]
    i_approx = gauss_quadrature(f, n)
    err = abs(i_approx - I_EXACTA)
    
    # Construcción del polinomio interpolador sobre nodos de Gauss
    y_interp = [sum(f(nodos[i]) * lagrange_basis(x, nodos, i) for i in 1:n) for x in x_fine]
    
    p = plot(x_fine, y_real, label="f(x) Real", lw=2.5, color=:blue,
             title="Cuadratura Gaussiana (n = $n)",
             subtitle="Aprox: $(round(i_approx, digits=6)) | Error: $(round(err, sigdigits=3))",
             xlims=(-1.1, 1.1), ylims=(0, 4.5), legend=:topright)
             
    # Área bajo el polinomio interpolador
    plot!(p, x_fine, y_interp, fill=(0, 0.3, :orange), label="Área de Gauss (Interpolante)", lw=2, linestyle=:dash, color=:darkorange)
    
    # Graficar los nodos de Legendre en el eje X con barras verticales
    scatter!(p, nodos, f.(nodos), label="Nodos Legendre ($n)", mc=:crimson, ms=8)
    vline!(p, nodos, linestyle=:dot, color=:gray, label="")
end

# Guardar GIF y estado final
gif(anim, "gauss_animacion.gif", fps=1)
savefig("gauss_final_n5.png")

println("-> Archivos 'gauss_animacion.gif' y 'gauss_final_n5.png' guardados con éxito.")