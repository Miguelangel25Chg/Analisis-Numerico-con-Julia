using Pkg
Pkg.add(["Plots", "Measures"])
using Plots
using Measures

# --- 1. DEFINICIÓN DEL MODELO ---
f(x) = 4 / (1 + x^2)

# Base de Lagrange L_i(x)
function lagrange_basis(x, nodes, i)
    L = 1.0
    for j in 1:length(nodes)
        if j != i
            L *= (x - nodes[j]) / (nodes[i] - nodes[j])
        end
    end
    return L
end

# Polinomio Interpolador P(x)
function lagrange_interp(x, nodes, values)
    P = 0.0
    for i in 1:length(nodes)
        P += values[i] * lagrange_basis(x, nodes, i)
    end
    return P
end

# --- 2. GENERACIÓN DE LA GRÁFICA ESTÁTICA ---
x_fine = range(-1, 1, length=300)
y_real = f.(x_fine)

# Nodos de prueba (ejemplo con 4 nodos equiespaciados)
nodos = range(-0.8, 0.8, length=4)
valores = f.(nodos)
y_interp = [lagrange_interp(x, nodos, valores) for x in x_fine]

# Crear la figura estática
plt = plot(x_fine, y_real, label="f(x) Real", lw=2.5, color=:blue,
           title="Interpolación de Lagrange (n = 4)",
           xlabel="x", ylabel="y", legend=:bottom)

plot!(plt, x_fine, y_interp, label="P(x) Lagrange", lw=2, linestyle=:dash, color=:red)
scatter!(plt, nodos, valores, label="Nodos de Interpolación", mc=:black, ms=6)

# Guardar imagen en PNG y SVG (vectorial para presentaciones/artículos)
savefig(plt, "lagrange_estatico.png")
savefig(plt, "lagrange_estatico.svg")
println("-> Gráfica estática guardada como 'lagrange_estatico.png' y '.svg'")

# --- 3. ANIMACIÓN: VECINDAD DINÁMICA DE NODOS (AGREGANDO PUNTOS) ---
# Mostramos cómo mejora la interpolación al subir el número de nodos de 2 a 10
println("-> Generando animación GIF...")

anim = @animate for n in 2:10
    nodos_dyn = range(-0.9, 0.9, length=n)
    valores_dyn = f.(nodos_dyn)
    y_interp_dyn = [lagrange_interp(x, nodos_dyn, valores_dyn) for x in x_fine]
    
    # Gráfica por cada frame
    p = plot(x_fine, y_real, label="f(x) Real", lw=2, color=:blue,
             title="Interpolación de Lagrange con Nodos Equiespaciados",
             subtitle="Número de Nodos (n) = $n",
             xlims=(-1.1, 1.1), ylims=(0, 4.5),
             legend=:topright)
             
    plot!(p, x_fine, y_interp_dyn, label="P_$n(x)", lw=2, linestyle=:dash, color=:crimson)
    scatter!(p, nodos_dyn, valores_dyn, label="Nodos ($n)", mc=:darkgreen, ms=5+n)
end

# Guardar la animación GIF
gif(anim, "lagrange_animacion.gif", fps=2)
println("-> Animación guardada exitosamente como 'lagrange_animacion.gif'")