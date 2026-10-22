// ============================================================
// GUI DE INTERPOLACION DE LAGRANGE  (version con interfaz mejorada)
// No se usa polyfit, interp1, lagrange() ni ningun comando que
// resuelva la interpolacion de forma directa. Las bases Lk(x)
// y el polinomio final P(x) se construyen manualmente con la
// formula de Lagrange, tal como en el desarrollo teorico:
//
//        n
// Lk(x) = PROD  (x - xi) / (xk - xi)     , i <> k
//       i = 1
//
//        n
// P(x) = SUMA  yk * Lk(x)
//       k = 1
//
// El usuario ingresa los valores X y Y para construir las bases
// L1(x), L2(x), ..., Ln(x) y el polinomio interpolante P(x).
// ============================================================

clear;
clc;

// Variables compartidas entre los callbacks del GUI.
// Se declaran una por una para evitar errores de compatibilidad
// con la instruccion global en algunas versiones de Scilab.
global hVentana;
global hX;
global hY;
global hSalida;
global hEstado;
global hTituloResultado;

// ------------------------------------------------------------
// Paleta de colores de la interfaz
// ------------------------------------------------------------
global colFondo;
global colHeader;
global colFrame;
global colBoton;
global colBotonOk;
global colBotonLimpiar;
global colBotonCerrar;
global colBotonEjemplo;
global colTextoClaro;
global colOk;
global colError;
global colNeutro;

colFondo          = [0.93 0.95 0.98];
colHeader         = [0.10 0.20 0.38];
colFrame          = [1.00 1.00 1.00];
colBoton          = [0.16 0.45 0.74];
colBotonOk        = [0.16 0.55 0.32];
colBotonLimpiar   = [0.55 0.55 0.58];
colBotonCerrar    = [0.70 0.20 0.20];
colBotonEjemplo   = [0.62 0.42 0.10];
colTextoClaro     = [1.00 1.00 1.00];
colOk             = [0.05 0.45 0.10];
colError          = [0.72 0.05 0.05];
colNeutro         = [0.10 0.10 0.10];

// ------------------------------------------------------------
// Lee un vector de numeros ingresado como texto.
// Ejemplo valido: -1 2 3   o   -1, 2, 3
// ------------------------------------------------------------
function [ok, v, mensaje] = leer_vector(cadena, nombre)
    ok = %f;
    v = [];
    mensaje = "";

    cadena = stripblanks(cadena);
    cadena = strsubst(cadena, "[", "");
    cadena = strsubst(cadena, "]", "");
    cadena = strsubst(cadena, ",", " ");
    cadena = strsubst(cadena, ";", " ");

    if length(cadena) == 0 then
        mensaje = "Ingrese los valores de " + nombre + ".";
        return;
    end

    [v, ierr] = evstr("[" + cadena + "]");

    if ierr <> 0 then
        mensaje = "Los valores de " + nombre + " no tienen un formato valido.";
        return;
    end

    if type(v) <> 1 then
        mensaje = "Los valores de " + nombre + " deben ser numericos.";
        return;
    end

    v = matrix(v, 1, size(v, "*"));

    if size(v, "*") == 0 then
        mensaje = "Ingrese al menos un valor en " + nombre + ".";
        return;
    end

    if or(imag(v) <> 0) then
        mensaje = "Los valores de " + nombre + " deben ser reales.";
        return;
    end

    if or(isnan(v)) | or(abs(v) == %inf) then
        mensaje = "Los valores de " + nombre + " deben ser finitos.";
        return;
    end

    if or(abs(v) > 1d8) then
        mensaje = "Los valores de " + nombre + " son demasiado grandes (limite 1e8).";
        return;
    end

    ok = %t;
endfunction

// ------------------------------------------------------------
// Construye el desarrollo textual de una base Lk(x):
// Lk(x) = producto [(x - xj) / (xk - xj)], con j distinto de k.
// ------------------------------------------------------------
function texto = desarrollo_base(x, k)
    n = size(x, "*");
    texto = "   L" + string(k) + "(x) = ";
    primero = %t;

    for j = 1:n
        if j <> k then
            factor = msprintf("[(x - (%g)) / ((%g) - (%g))]", x(j), x(k), x(j));

            if primero then
                texto = texto + factor;
                primero = %f;
            else
                texto = texto + " * " + factor;
            end
        end
    end
endfunction

// ------------------------------------------------------------
// Muestra un mensaje de error en el GUI (texto y color rojo).
// ------------------------------------------------------------
function mostrar_error(mensaje)
    global hSalida hEstado colError;

    set(hEstado, "string", "Estado:  " + mensaje);
    set(hEstado, "foregroundcolor", colError);

    set(hSalida, "string", [
        "  >> ERROR AL PROCESAR LOS DATOS";
        "  " + mensaje;
        "  Corrija los valores y presione nuevamente Calcular y graficar."
    ]);
endfunction

// ------------------------------------------------------------
// Crea las dos graficas:
// 1. Polinomio interpolante y puntos originales.
// 2. Bases de Lagrange L1, L2, ..., Ln.
// ------------------------------------------------------------
function graficar_lagrange(x, y, p, Lbases)
    n = size(x, "*");

    rango = max(x) - min(x);
    margen = max(0.20 * rango, 1);
    xx = linspace(min(x) - margen, max(x) + margen, 500);
    yy = horner(p, xx);

    // ---------- Grafica 1: polinomio final y puntos originales ----------
    f1 = figure(101);
    clf(f1);
    f1.figure_name = "Interpolacion de Lagrange - Polinomio final";
    f1.position = [80 70 820 580];
    f1.background = color(255, 255, 255);

    // plot() devuelve los handles de las curvas creadas.
    // Asi no dependemos de gce() ni de la propiedad children.
    curva = plot(xx, yy);
    curva.thickness = 3;
    curva.foreground = color(30, 144, 255);

    puntos = plot(x, y);
    puntos.line_mode = "off";
    puntos.mark_mode = "on";
    puntos.mark_style = 9;
    puntos.mark_size = 9;
    puntos.mark_foreground = color(220, 50, 47);
    puntos.mark_background = color(220, 50, 47);

    ejes1 = gca();
    ejes1.background = color(250, 250, 253);
    ejes1.font_size = 2;
    xgrid(color(190, 190, 190));

    xtitle("Polinomio interpolante de Lagrange P(x)", "x", "y");
    legend([curva; puntos], ["P(x)"; "Puntos originales"], "in_upper_left");

    // ---------- Grafica 2: todas las bases Lk(x) ----------
    basesY = zeros(size(xx, "*"), n);
    etiquetas = emptystr(1, n);

    paleta = [
        0.00 0.45 0.74;
        0.85 0.33 0.10;
        0.47 0.67 0.19;
        0.49 0.18 0.56;
        0.93 0.69 0.13;
        0.30 0.75 0.93;
        0.64 0.08 0.18;
        0.00 0.50 0.50;
        0.60 0.20 0.80;
        0.20 0.20 0.20
    ];

    for k = 1:n
        basesY(:, k) = horner(Lbases(k), xx)';
        etiquetas(k) = "L" + string(k) + "(x)";
    end

    f2 = figure(102);
    clf(f2);
    f2.figure_name = "Interpolacion de Lagrange - Bases Lk(x)";
    f2.position = [930 70 820 580];
    f2.background = color(255, 255, 255);

    // xx' es columna (500x1) y basesY es 500xn.
    // plot devuelve un handle por cada base Lk.
    curvas = plot(xx', basesY);

    for k = 1:n
        idxColor = modulo(k - 1, size(paleta, 1)) + 1;
        curvas(k).foreground = color(round(paleta(idxColor, 1) * 255), ...
                                     round(paleta(idxColor, 2) * 255), ...
                                     round(paleta(idxColor, 3) * 255));
        curvas(k).thickness = 2;
    end

    ejes2 = gca();
    ejes2.background = color(250, 250, 253);
    ejes2.font_size = 2;
    xgrid(color(190, 190, 190));

    xtitle("Funciones base de Lagrange L1(x) ... Ln(x)", "x", "Lk(x)");
    legend(curvas, etiquetas, "in_upper_left");
endfunction

// ------------------------------------------------------------
// Calcula bases Lk, polinomio P(x), desarrollo y graficas.
// ------------------------------------------------------------
function lagrange_calcular()
    global hX hY hSalida hEstado colOk;

    [okX, x, mensajeX] = leer_vector(get(hX, "string"), "X");
    if ~okX then
        mostrar_error(mensajeX);
        return;
    end

    [okY, y, mensajeY] = leer_vector(get(hY, "string"), "Y");
    if ~okY then
        mostrar_error(mensajeY);
        return;
    end

    n = size(x, "*");

    // -------------------- Restricciones de entrada --------------------
    if n <> size(y, "*") then
        mostrar_error("X y Y deben tener la misma cantidad de valores.");
        return;
    end

    if n < 2 then
        mostrar_error("Se necesitan por lo menos 2 puntos para interpolar.");
        return;
    end

    // Los valores de X no se pueden repetir (evita division por cero
    // y resultados absurdos: nodos identicos no definen una funcion).
    tolerancia = 100 * %eps * max([1 abs(x)]);

    for i = 1:n-1
        for j = i+1:n
            if abs(x(i) - x(j)) <= tolerancia then
                mostrar_error("No se permiten valores de X repetidos o demasiado cercanos.");
                return;
            end
        end
    end

    // Si todos los puntos son identicos entre si en Y y ademas
    // coinciden con una recta constante trivial, se permite igual
    // (no es absurdo, es un caso valido), por lo que no se restringe.

    // -------------------- Construccion manual de Lagrange --------------------
    // Lk(x) = producto((z - xj)/(xk - xj)), con j diferente de k
    z = poly(0, "x");
    p = 0 * z;
    Lbases = list();

    k = 1;

while k <= n
    Lk = 1;
    j = 1;

    while j <= n
        if j <> k then
            Lk = Lk * (z - x(j)) / (x(k) - x(j));
        end

        j = j + 1;
    end

    Lbases(k) = Lk;
    p = p + y(k) * Lk;

    k = k + 1;
end

c = coeff(p);

i = 1;
while i <= length(c)
    if abs(c(i)) < 1D-10 then
        c(i) = 0;
    end

    i = i + 1;
end

p = poly(c, "x", "coeff");

    // Evaluacion del polinomio en los x originales.
    yTeorico = horner(p, x);
    error = 0;

    // -------------------- Preparar salida de texto --------------------
    lineas = [
        "==================================================================";
        "   RESULTADOS - INTERPOLACION DE LAGRANGE";
        "==================================================================";
        "  Cantidad de puntos ingresados : " + string(n);
        " ";
        "  DESARROLLO DE LAS BASES DE LAGRANGE:";
        "  ------------------------------------------------------------"
    ];

    for k = 1:n
        lineas($+1) = desarrollo_base(x, k);
        lineas($+1) = "          = " + pol2str(Lbases(k));
    end

    lineas($+1) = " ";
    lineas($+1) = "  POLINOMIO INTERPOLANTE FINAL:";
    lineas($+1) = "  ------------------------------------------------------------";
    lineas($+1) = "   P(x) = " + pol2str(p);
    lineas($+1) = " ";
    lineas($+1) = "  VERIFICACION EN LOS PUNTOS ORIGINALES:";
    lineas($+1) = "  ------------------------------------------------------------";
    lineas($+1) = "   i      x_i          y original      y teorico";

    for k = 1:n
        lineas($+1) = msprintf( ...
            "  %2d   %12.6g   %12.6g   %12.6g", ...
            k, x(k), y(k), yTeorico(k));
    end

    lineas($+1) = "==================================================================";

    set(hSalida, "string", lineas);
    set(hEstado, "string", "Estado:  Calculo realizado correctamente. Revise el desarrollo y las 2 ventanas graficas.");
    set(hEstado, "foregroundcolor", colOk);

    graficar_lagrange(x, y, p, Lbases);
endfunction

// ------------------------------------------------------------
// Limpia los campos del GUI.
// ------------------------------------------------------------
function lagrange_limpiar()
    global hX hY hSalida hEstado colNeutro;

    set(hX, "string", "");
    set(hY, "string", "");
    set(hSalida, "string", [
        "  Ingrese los puntos y presione Calcular y graficar.";
        "  Se permiten n puntos (minimo 2, sin limite maximo).";
        "  Use espacios o comas para separar los numeros."
    ]);
    set(hEstado, "string", "Estado:  Esperando datos.");
    set(hEstado, "foregroundcolor", colNeutro);
endfunction

// ------------------------------------------------------------
// Carga un ejemplo de referencia en los campos (el usuario
// puede borrarlo o modificarlo libremente; no queda nada fijo).
// ------------------------------------------------------------
function lagrange_ejemplo()
    global hX hY hEstado colNeutro;

    set(hX, "string", "-1 2 3");
    set(hY, "string", "1 -2 5");
    set(hEstado, "string", "Estado:  Ejemplo cargado. Puede editarlo o presionar Calcular y graficar.");
    set(hEstado, "foregroundcolor", colNeutro);
endfunction

// ------------------------------------------------------------
// Cierra la ventana principal y las graficas asociadas.
// ------------------------------------------------------------
function lagrange_cerrar()
    global hVentana;

    // Cierra la ventana principal mediante su handle.
    if is_handle_valid(hVentana) then
        delete(hVentana);
    end

    // Cierra solamente las dos figuras de resultados.
    ventanasAbiertas = winsid();
    for id = ventanasAbiertas
        if id == 101 | id == 102 then
            hFigura = get_figure_handle(id);
            if size(hFigura, "*") > 0 then
                delete(hFigura);
            end
        end
    end
endfunction

// ------------------------------------------------------------
// Ventana principal del GUI.
// ------------------------------------------------------------
function lagrange_gui()
    global hVentana;
    global hX;
    global hY;
    global hSalida;
    global hEstado;
    global colFondo;
    global colHeader;
    global colFrame;
    global colBoton;
    global colBotonOk;
    global colBotonLimpiar;
    global colBotonCerrar;
    global colBotonEjemplo;
    global colTextoClaro;
    global colNeutro;

    // menubar y toolbar se deben definir al CREAR la figura.
    // Configurarlos despues provoca que el script se detenga.
    hAnterior = findobj("tag", "LAGRANGE_GUI_PRINCIPAL");
    if size(hAnterior, "*") > 0 then
        delete(hAnterior);
    end

    hVentana = figure( ...
        "dockable", "off", ...
        "menubar", "none", ...
        "toolbar", "none", ...
        "default_axes", "off", ...
        "tag", "LAGRANGE_GUI_PRINCIPAL");

    hVentana.figure_name = "GUI - Interpolacion de Lagrange";
    hVentana.position = [80 40 1180 690];
    hVentana.background = color(round(colFondo(1)*255), ...
                                 round(colFondo(2)*255), ...
                                 round(colFondo(3)*255));
    hVentana.resize = "off";

    // -------- Barra de titulo (encabezado de color) --------
    uicontrol(hVentana, ...
        "style", "text", ...
        "position", [0 650 1180 40], ...
        "string", "INTERPOLACION DE LAGRANGE", ...
        "fontsize", 19, ...
        "fontweight", "bold", ...
        "backgroundcolor", colHeader, ...
        "foregroundcolor", colTextoClaro, ...
        "horizontalalignment", "center");

    // -------- Marco de ingreso de datos --------
    uicontrol(hVentana, ...
        "style", "frame", ...
        "position", [20 330 425 275], ...
        "backgroundcolor", colFrame);

    uicontrol(hVentana, ...
        "style", "text", ...
        "position", [30 570 405 24], ...
        "string", "DATOS DE LA MUESTRA", ...
        "fontsize", 13, ...
        "fontweight", "bold", ...
        "backgroundcolor", colFrame, ...
        "horizontalalignment", "left");

    uicontrol(hVentana, ...
        "style", "text", ...
        "position", [38 528 385 22], ...
        "string", "Valores de X", ...
        "fontsize", 11, ...
        "backgroundcolor", colFrame, ...
        "horizontalalignment", "left");

    hX = uicontrol(hVentana, ...
        "style", "edit", ...
        "position", [38 496 385 30], ...
        "string", "", ...
        "fontsize", 12, ...
        "backgroundcolor", [1 1 1], ...
        "horizontalalignment", "left");

    uicontrol(hVentana, ...
        "style", "text", ...
        "position", [38 448 385 22], ...
        "string", "Valores de Y", ...
        "fontsize", 11, ...
        "backgroundcolor", colFrame, ...
        "horizontalalignment", "left");

    hY = uicontrol(hVentana, ...
        "style", "edit", ...
        "position", [38 416 385 30], ...
        "string", "", ...
        "fontsize", 12, ...
        "backgroundcolor", [1 1 1], ...
        "horizontalalignment", "left");

    uicontrol(hVentana, ...
        "style", "text", ...
        "position", [38 372 385 36], ...
        "string", "Separe con espacios o comas. Minimo 2 puntos (n libre). X no puede repetirse.", ...
        "fontsize", 9, ...
        "backgroundcolor", colFrame, ...
        "fontweight", "bold", ...
        "horizontalalignment", "left");

    uicontrol(hVentana, ...
        "style", "pushbutton", ...
        "position", [38 337 385 28], ...
        "string", "Cargar ejemplo (-1,1) (2,-2) (3,5)", ...
        "fontsize", 10, ...
        "backgroundcolor", colBotonEjemplo, ...
        "foregroundcolor", colTextoClaro, ...
        "callback", "lagrange_ejemplo();");

    // -------- Botones de accion --------
    uicontrol(hVentana, ...
        "style", "pushbutton", ...
        "position", [20 275 425 40], ...
        "string", "CALCULAR Y GRAFICAR", ...
        "fontsize", 14, ...
        "fontweight", "bold", ...
        "backgroundcolor", colBotonOk, ...
        "foregroundcolor", colTextoClaro, ...
        "callback", "lagrange_calcular();");

    uicontrol(hVentana, ...
        "style", "pushbutton", ...
        "position", [20 225 205 38], ...
        "string", "Limpiar", ...
        "fontsize", 12, ...
        "backgroundcolor", colBotonLimpiar, ...
        "foregroundcolor", colTextoClaro, ...
        "callback", "lagrange_limpiar();");

    uicontrol(hVentana, ...
        "style", "pushbutton", ...
        "position", [240 225 205 38], ...
        "string", "Cerrar", ...
        "fontsize", 12, ...
        "backgroundcolor", colBotonCerrar, ...
        "foregroundcolor", colTextoClaro, ...
        "callback", "lagrange_cerrar();");

    // -------- Area de resultados --------
    uicontrol(hVentana, ...
        "style", "frame", ...
        "position", [465 185 695 420], ...
        "backgroundcolor", colFrame);

    uicontrol(hVentana, ...
        "style", "text", ...
        "position", [478 570 670 24], ...
        "string", "RESULTADOS", ...
        "fontsize", 13, ...
        "fontweight", "bold", ...
        "backgroundcolor", colFrame, ...
        "horizontalalignment", "left");

    hSalida = uicontrol(hVentana, ...
        "style", "listbox", ...
        "position", [478 200 670 365], ...
        "string", [
            "  Ingrese los puntos y presione Calcular y graficar.";
            "  Se mostrara el desarrollo de las bases L1, L2, ..., Ln.";
            "  Tambien se mostrara el polinomio P(x) y la verificacion."
        ], ...
        "fontsize", 10, ...
        "fontname", "courier", ...
        "backgroundcolor", [1 1 1]);

    // -------- Estado e instrucciones inferiores --------
    hEstado = uicontrol(hVentana, ...
        "style", "text", ...
        "position", [20 140 1140 26], ...
        "string", "Estado:  Esperando datos.", ...
        "fontsize", 11, ...
        "fontweight", "bold", ...
        "backgroundcolor", colFondo, ...
        "foregroundcolor", colNeutro, ...
        "horizontalalignment", "left");

    uicontrol(hVentana, ...
        "style", "text", ...
        "position", [20 55 1140 75], ...
        "string", [
            "Restricciones aplicadas: X y Y deben tener la misma cantidad de valores; se necesitan minimo 2 puntos (n es libre, sin limite maximo);";
            "los valores de X no pueden repetirse (evita division por cero) y deben ser numeros reales y finitos (limite +/-1e8).";
            "Se abren dos ventanas: (1) el polinomio P(x) con los puntos originales, y (2) las bases L1(x), L2(x), ..., Ln(x)."
        ], ...
        "fontsize", 9, ...
        "backgroundcolor", colFondo, ...
        "horizontalalignment", "left");
endfunction

// Ejecutar el GUI
lagrange_gui();
