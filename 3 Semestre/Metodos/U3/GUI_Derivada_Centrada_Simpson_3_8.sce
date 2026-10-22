// ============================================================================
// GUI: DERIVADA CENTRADA Y SIMPSON 3/8 EXTENDIDO
// Autor: Iker Mathews Guallo Vera
//
// El programa:
// 1) Calcula una derivada mediante diferencia centrada.
// 2) Calcula una integral mediante Simpson compuesto 3/8.
// 3) Permite modificar libremente la funcion.
// 4) Repite el proceso hasta alcanzar el error relativo solicitado
//    (el numero de iteraciones lo administra el propio sistema).
// 5) Muestra todos los valores obtenidos en cada iteracion.
//
// IMPORTANTE:
// - Para funciones trigonometricas, ingrese los valores en radianes.
// - La derivada de referencia se obtiene con numderivative solamente para
//   calcular el error; la aproximacion se programa manualmente.
// - La integral de referencia se obtiene con intg solamente para calcular
//   el error; Simpson 3/8 se programa manualmente.
// ============================================================================

clc;
funcprot(0);

// -----------------------------
// Variables globales de la GUI
// -----------------------------
global ventanaPrincipal;

global txtDerFuncion txtDerX txtDerH txtDerError;
global tablaDerivada lblDerReferencia lblDerResultado lblDerEstado;

global txtIntFuncion txtIntA txtIntB txtIntError;
global tablaIntegral lblIntReferencia lblIntResultado lblIntEstado;

// -----------------------------
// Paleta de colores de la interfaz
// -----------------------------
global COLOR_FONDO COLOR_PANEL_DER COLOR_PANEL_INT;
global COLOR_TITULO_DER COLOR_TITULO_INT;
global COLOR_BTN_CALC_DER COLOR_BTN_CALC_INT COLOR_BTN_EJEMPLO COLOR_BTN_LIMPIAR;
global COLOR_INFO COLOR_OK COLOR_WARN COLOR_ERROR;

COLOR_FONDO       = [0.91 0.94 0.98];
COLOR_PANEL_DER   = [0.92 0.96 1.00];
COLOR_PANEL_INT   = [0.93 0.99 0.94];
COLOR_TITULO_DER  = [0.06 0.27 0.55];
COLOR_TITULO_INT  = [0.07 0.42 0.20];
COLOR_BTN_CALC_DER = [0.16 0.45 0.80];
COLOR_BTN_CALC_INT = [0.20 0.58 0.32];
COLOR_BTN_EJEMPLO  = [0.95 0.72 0.25];
COLOR_BTN_LIMPIAR  = [0.80 0.30 0.28];
COLOR_INFO  = [0.15 0.35 0.65];
COLOR_OK    = [0.10 0.55 0.20];
COLOR_WARN  = [0.80 0.45 0.05];
COLOR_ERROR = [0.75 0.15 0.15];

// -----------------------------
// Limites internos de seguridad
// (el usuario ya no los ingresa; el sistema itera segun el error)
// -----------------------------
global LIMITE_ITER_DER LIMITE_ITER_INT;
LIMITE_ITER_DER = 20;
LIMITE_ITER_INT = 18;


// ============================================================================
// FUNCIONES AUXILIARES
// ============================================================================

// Lee un valor numerico desde un cuadro de texto.
// Acepta expresiones de Scilab como %pi/4, sqrt(2), 1/3, etc.
function valor = leerEscalar(cadena, nombreCampo)
    cadena = stripblanks(cadena);

    if cadena == "" then
        error("El campo """ + nombreCampo + """ no puede estar vacio.");
    end

    try
        valor = evstr(cadena);
    catch
        error("El campo """ + nombreCampo + """ no contiene un valor valido.");
    end

    if size(valor, "*") <> 1 then
        error("El campo """ + nombreCampo + """ debe contener un solo valor.");
    end

    if ~isreal(valor) then
        error("El campo """ + nombreCampo + """ debe ser un numero real.");
    end

    if or(isnan(valor)) | or(abs(valor) == %inf) then
        error("El campo """ + nombreCampo + """ debe ser finito.");
    end
endfunction


// Evalua la expresion escrita por el usuario usando la variable local x.
// Esta funcion tambien puede enviarse a numderivative e intg mediante list().
function y = evaluarFuncion(x, expresion)
    y = evstr(expresion);
endfunction


// Comprueba que el usuario haya ingresado una expresion.
function expresion = leerExpresion(cadena)
    expresion = stripblanks(cadena);

    if expresion == "" then
        error("Debe ingresar una funcion.");
    end
endfunction


// Verifica que el resultado de evaluar la funcion sea util para los metodos.
function validarEvaluacion(valor, punto)
    if size(valor, "*") <> 1 then
        error(msprintf("La funcion no devuelve un escalar en x = %.10f.", punto));
    end

    if ~isreal(valor) then
        error(msprintf("La funcion genera un valor complejo en x = %.10f.", punto));
    end

    if or(isnan(valor)) | or(abs(valor) == %inf) then
        error(msprintf("La funcion no esta definida o no es finita en x = %.10f.", punto));
    end
endfunction


// Simpson 3/8 compuesto programado manualmente.
// n debe ser multiplo de 3.
function integralAprox = simpsonTresOctavos(a, b, n, expresion)
    if modulo(n, 3) <> 0 then
        error("En Simpson 3/8, n debe ser multiplo de 3.");
    end

    h = (b - a) / n;

    fa = evaluarFuncion(a, expresion);
    fb = evaluarFuncion(b, expresion);
    validarEvaluacion(fa, a);
    validarEvaluacion(fb, b);

    suma = fa + fb;

    i = 1;
    while i <= (n - 1)
        xi = a + i*h;
        yi = evaluarFuncion(xi, expresion);
        validarEvaluacion(yi, xi);

        if modulo(i, 3) == 0 then
            suma = suma + 2*yi;
        else
            suma = suma + 3*yi;
        end

        i = i + 1;
    end

    integralAprox = (3*h/8) * suma;
endfunction


// ============================================================================
// MODULO 1: DERIVADA CENTRADA
// ============================================================================

function calcularDerivadaCentrada()
    global txtDerFuncion txtDerX txtDerH txtDerError;
    global tablaDerivada lblDerReferencia lblDerResultado lblDerEstado;
    global LIMITE_ITER_DER COLOR_INFO COLOR_OK COLOR_WARN COLOR_ERROR;

    set(lblDerEstado, "string", "Estado: calculando...");
    set(lblDerEstado, "foregroundcolor", COLOR_INFO);

    try
        expresion = leerExpresion(get(txtDerFuncion, "string"));
        x0 = leerEscalar(get(txtDerX, "string"), "x");
        h = leerEscalar(get(txtDerH, "string"), "h inicial");
        tolerancia = leerEscalar(get(txtDerError, "string"), "error permitido");

        if h <= 0 then
            error("El valor de h debe ser mayor que cero.");
        end

        if tolerancia <= 0 then
            error("El error permitido debe ser mayor que cero.");
        end

        // Se usa solo como valor de referencia para calcular el error.
        try
            derivadaReal = numderivative(list(evaluarFuncion, expresion), x0);
        catch
            error("No se pudo obtener la derivada de referencia en el punto indicado.");
        end

        validarEvaluacion(derivadaReal, x0);

        if abs(derivadaReal) < 1d-14 then
            error("La derivada de referencia es cero o muy cercana a cero; el error relativo no esta definido. Cambie x o la funcion.");
        end

        encabezado = "Iter | Derivada aprox. | Derivada ref. |  Error (%)";
        lineas = encabezado;

        alcanzado = %f;
        aproximacion = %nan;
        errorRelativo = %nan;
        iteracion = 0;
        continuar = %t;

        while continuar
            iteracion = iteracion + 1;

            if h <= %eps * max([1 abs(x0)]) then
                error("h llego al limite de precision numerica antes de alcanzar la tolerancia.");
            end

            xIzquierda = x0 - h;
            xDerecha = x0 + h;

            fIzquierda = evaluarFuncion(xIzquierda, expresion);
            fDerecha = evaluarFuncion(xDerecha, expresion);

            validarEvaluacion(fIzquierda, xIzquierda);
            validarEvaluacion(fDerecha, xDerecha);

            // FORMULA DE DIFERENCIA CENTRADA
            aproximacion = (fDerecha - fIzquierda) / (2*h);

            // ERROR RELATIVO PORCENTUAL
            errorRelativo = abs((derivadaReal - aproximacion) / derivadaReal) * 100;

            fila = msprintf("%4d | %15.8f | %13.8f | %11.7f", ..
                            iteracion, aproximacion, derivadaReal, errorRelativo);

            lineas($ + 1) = fila;
            set(tablaDerivada, "string", lineas);
            set(tablaDerivada, "value", size(lineas, "*"));

            if errorRelativo <= tolerancia then
                alcanzado = %t;
                continuar = %f;
            elseif iteracion >= LIMITE_ITER_DER then
                continuar = %f;
            else
                // Igual que en el ejemplo: 0.1, 0.01, 0.001, ...
                h = h / 10;
            end
        end

        set(lblDerReferencia, "string", msprintf("Derivada de referencia: %.12f", derivadaReal));
        set(lblDerResultado, "string", msprintf("Ultima aproximacion: %.12f    Error: %.10f %%", ..
                                                aproximacion, errorRelativo));

        if alcanzado then
            set(lblDerEstado, "string", msprintf("Estado: tolerancia alcanzada en %d iteracion(es).", iteracion));
            set(lblDerEstado, "foregroundcolor", COLOR_OK);
        else
            set(lblDerEstado, "string", "Estado: no se alcanzo la tolerancia dentro del limite de iteraciones del sistema.");
            set(lblDerEstado, "foregroundcolor", COLOR_WARN);
            messagebox("No se alcanzo el error solicitado dentro del limite de iteraciones. Revise la funcion o el error permitido.", ..
                       "Advertencia", "warning");
        end

    catch
        set(lblDerEstado, "string", "Estado: error en los datos.");
        set(lblDerEstado, "foregroundcolor", COLOR_ERROR);
        messagebox(lasterror(), "Error - Derivada centrada", "error");
    end
endfunction


function ejemploDerivada()
    global txtDerFuncion txtDerX txtDerH txtDerError;

    set(txtDerFuncion, "string", "log(x)*sin(x^2)");
    set(txtDerX, "string", "%pi/4");
    set(txtDerH, "string", "0.1");
    set(txtDerError, "string", "0.01");
endfunction


function limpiarDerivada()
    global txtDerFuncion txtDerX txtDerH txtDerError;
    global tablaDerivada lblDerReferencia lblDerResultado lblDerEstado;
    global COLOR_INFO;

    set(txtDerFuncion, "string", "");
    set(txtDerX, "string", "");
    set(txtDerH, "string", "");
    set(txtDerError, "string", "");

    set(tablaDerivada, "string", ..
        ["Iter | Derivada aprox. | Derivada ref. |  Error (%)"]);
    set(lblDerReferencia, "string", "Derivada de referencia: --");
    set(lblDerResultado, "string", "Ultima aproximacion: --");
    set(lblDerEstado, "string", "Estado: listo.");
    set(lblDerEstado, "foregroundcolor", COLOR_INFO);
endfunction


// ============================================================================
// MODULO 2: SIMPSON 3/8 EXTENDIDO
// ============================================================================

function calcularSimpsonExtendido()
    global txtIntFuncion txtIntA txtIntB txtIntError;
    global tablaIntegral lblIntReferencia lblIntResultado lblIntEstado;
    global LIMITE_ITER_INT COLOR_INFO COLOR_OK COLOR_WARN COLOR_ERROR;

    set(lblIntEstado, "string", "Estado: calculando...");
    set(lblIntEstado, "foregroundcolor", COLOR_INFO);

    try
        expresion = leerExpresion(get(txtIntFuncion, "string"));
        a = leerEscalar(get(txtIntA, "string"), "a");
        b = leerEscalar(get(txtIntB, "string"), "b");
        tolerancia = leerEscalar(get(txtIntError, "string"), "error permitido");

        if a == b then
            error("Los limites a y b no pueden ser iguales.");
        end

        if tolerancia <= 0 then
            error("El error permitido debe ser mayor que cero.");
        end

        // Se usa intg solamente para obtener el valor real de referencia.
        // La regla de Simpson 3/8 se calcula manualmente en simpsonTresOctavos().
        try
            integralReal = intg(a, b, list(evaluarFuncion, expresion));
        catch
            error("No se pudo obtener la integral de referencia. Revise el dominio y la continuidad de la funcion entre a y b.");
        end

        validarEvaluacion(integralReal, (a + b)/2);

        if abs(integralReal) < 1d-14 then
            error("La integral de referencia es cero o muy cercana a cero; el error relativo no esta definido. Cambie los limites o la funcion.");
        end

        encabezado = "Iter |    n    | Integral aprox. | Integral ref. |  Error (%)";
        lineas = encabezado;

        n = 3;
        alcanzado = %f;
        aproximacion = %nan;
        errorRelativo = %nan;
        iteracion = 0;
        continuar = %t;

        while continuar
            iteracion = iteracion + 1;

            aproximacion = simpsonTresOctavos(a, b, n, expresion);

            // ERROR RELATIVO PORCENTUAL
            errorRelativo = abs((integralReal - aproximacion) / integralReal) * 100;

            fila = msprintf("%4d | %7d | %15.8f | %13.8f | %11.7f", ..
                            iteracion, n, aproximacion, integralReal, errorRelativo);

            lineas($ + 1) = fila;
            set(tablaIntegral, "string", lineas);
            set(tablaIntegral, "value", size(lineas, "*"));

            if errorRelativo <= tolerancia then
                alcanzado = %t;
                continuar = %f;
            elseif iteracion >= LIMITE_ITER_INT then
                continuar = %f;
            else
                // 3, 6, 12, 24, ... siempre son multiplos de 3.
                n = n * 2;
            end
        end

        set(lblIntReferencia, "string", msprintf("Integral de referencia (intg): %.12f", integralReal));
        set(lblIntResultado, "string", msprintf("Ultima aproximacion: %.12f    Error: %.10f %%    n = %d", ..
                                                aproximacion, errorRelativo, n));

        if alcanzado then
            set(lblIntEstado, "string", msprintf("Estado: tolerancia alcanzada en %d iteracion(es).", iteracion));
            set(lblIntEstado, "foregroundcolor", COLOR_OK);
        else
            set(lblIntEstado, "string", "Estado: no se alcanzo la tolerancia dentro del limite de iteraciones del sistema.");
            set(lblIntEstado, "foregroundcolor", COLOR_WARN);
            messagebox("No se alcanzo el error solicitado dentro del limite de iteraciones. Revise la funcion o el error permitido.", ..
                       "Advertencia", "warning");
        end

    catch
        set(lblIntEstado, "string", "Estado: error en los datos.");
        set(lblIntEstado, "foregroundcolor", COLOR_ERROR);
        messagebox(lasterror(), "Error - Simpson 3/8", "error");
    end
endfunction


function ejemploSimpson()
    global txtIntFuncion txtIntA txtIntB txtIntError;

    set(txtIntFuncion, "string", "exp(x)");
    set(txtIntA, "string", "0");
    set(txtIntB, "string", "0.2");
    set(txtIntError, "string", "0.001");
endfunction


function limpiarSimpson()
    global txtIntFuncion txtIntA txtIntB txtIntError;
    global tablaIntegral lblIntReferencia lblIntResultado lblIntEstado;
    global COLOR_INFO;

    set(txtIntFuncion, "string", "");
    set(txtIntA, "string", "");
    set(txtIntB, "string", "");
    set(txtIntError, "string", "");

    set(tablaIntegral, "string", ..
        ["Iter |    n    | Integral aprox. | Integral ref. |  Error (%)"]);
    set(lblIntReferencia, "string", "Integral de referencia (intg): --");
    set(lblIntResultado, "string", "Ultima aproximacion: --");
    set(lblIntEstado, "string", "Estado: listo.");
    set(lblIntEstado, "foregroundcolor", COLOR_INFO);
endfunction


// ============================================================================
// CONSTRUCCION DE LA INTERFAZ GRAFICA
// ============================================================================

function crearInterfaz()
    global ventanaPrincipal;

    global txtDerFuncion txtDerX txtDerH txtDerError;
    global tablaDerivada lblDerReferencia lblDerResultado lblDerEstado;

    global txtIntFuncion txtIntA txtIntB txtIntError;
    global tablaIntegral lblIntReferencia lblIntResultado lblIntEstado;

    global COLOR_FONDO COLOR_PANEL_DER COLOR_PANEL_INT;
    global COLOR_TITULO_DER COLOR_TITULO_INT;
    global COLOR_BTN_CALC_DER COLOR_BTN_CALC_INT COLOR_BTN_EJEMPLO COLOR_BTN_LIMPIAR;
    global COLOR_INFO;

    ventanaPrincipal = figure( ..
        "position", [30 25 1320 760], ..
        "figure_name", "Metodos numericos: Derivada centrada y Simpson 3/8", ..
        "backgroundcolor", COLOR_FONDO, ..
        "default_axes", "off", ..
        "dockable", "off", ..
        "resize", "off");

    ventanaPrincipal.menubar_visible = "off";
    ventanaPrincipal.toolbar_visible = "off";
    ventanaPrincipal.infobar_visible = "off";

    // TITULO GENERAL
    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [20 710 1280 35], ..
        "string", "DERIVADA CENTRADA Y SIMPSON 3/8 EXTENDIDO", ..
        "fontsize", 20, ..
        "fontweight", "bold", ..
        "backgroundcolor", COLOR_FONDO, ..
        "foregroundcolor", [0.10 0.16 0.30], ..
        "horizontalalignment", "center");

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [20 684 1280 24], ..
        "string", "Ingrese funciones con la variable x. Para trigonometria, use radianes: %pi, %pi/2, etc. El sistema itera automaticamente hasta cumplir el error solicitado.", ..
        "fontsize", 11, ..
        "backgroundcolor", COLOR_FONDO, ..
        "foregroundcolor", [0.30 0.34 0.40], ..
        "horizontalalignment", "center");

    // ------------------------------------------------------------------------
    // PANEL IZQUIERDO: DERIVADA
    // ------------------------------------------------------------------------
    uicontrol(ventanaPrincipal, ..
        "style", "frame", ..
        "position", [18 30 632 645], ..
        "backgroundcolor", COLOR_PANEL_DER);

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [35 630 598 30], ..
        "string", "1. DERIVADA POR DIFERENCIA CENTRADA", ..
        "fontsize", 15, ..
        "fontweight", "bold", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", COLOR_TITULO_DER, ..
        "horizontalalignment", "center");

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [38 594 100 23], ..
        "string", "Funcion f(x):", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", COLOR_TITULO_DER, ..
        "horizontalalignment", "left");

    txtDerFuncion = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [140 590 475 30], ..
        "string", "log(x)*sin(x^2)", ..
        "fontsize", 11, ..
        "backgroundcolor", [1 1 1], ..
        "horizontalalignment", "left");

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [38 550 45 23], ..
        "string", "x:", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", COLOR_TITULO_DER, ..
        "horizontalalignment", "left");

    txtDerX = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [70 546 105 30], ..
        "string", "%pi/4", ..
        "backgroundcolor", [1 1 1]);

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [190 550 70 23], ..
        "string", "h inicial:", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", COLOR_TITULO_DER, ..
        "horizontalalignment", "left");

    txtDerH = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [260 546 90 30], ..
        "string", "0.1", ..
        "backgroundcolor", [1 1 1]);

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [365 550 105 23], ..
        "string", "Error max. (%):", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", COLOR_TITULO_DER, ..
        "horizontalalignment", "left");

    txtDerError = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [470 546 140 30], ..
        "string", "0.01", ..
        "backgroundcolor", [1 1 1]);

    uicontrol(ventanaPrincipal, ..
        "style", "pushbutton", ..
        "position", [55 498 160 35], ..
        "string", "CALCULAR DERIVADA", ..
        "fontsize", 11, ..
        "fontweight", "bold", ..
        "backgroundcolor", COLOR_BTN_CALC_DER, ..
        "foregroundcolor", [1 1 1], ..
        "callback", "calcularDerivadaCentrada();");

    uicontrol(ventanaPrincipal, ..
        "style", "pushbutton", ..
        "position", [250 498 140 35], ..
        "string", "CARGAR EJEMPLO", ..
        "backgroundcolor", COLOR_BTN_EJEMPLO, ..
        "foregroundcolor", [0.30 0.20 0.02], ..
        "callback", "ejemploDerivada();");

    uicontrol(ventanaPrincipal, ..
        "style", "pushbutton", ..
        "position", [425 498 140 35], ..
        "string", "LIMPIAR TODO", ..
        "backgroundcolor", COLOR_BTN_LIMPIAR, ..
        "foregroundcolor", [1 1 1], ..
        "callback", "limpiarDerivada();");

    lblDerReferencia = uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [38 462 590 24], ..
        "string", "Derivada de referencia: --", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", COLOR_TITULO_DER, ..
        "horizontalalignment", "left", ..
        "fontweight", "bold");

    lblDerResultado = uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [38 438 590 24], ..
        "string", "Ultima aproximacion: --", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", [0.25 0.25 0.25], ..
        "horizontalalignment", "left");

    lblDerEstado = uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [38 414 590 24], ..
        "string", "Estado: listo.", ..
        "backgroundcolor", COLOR_PANEL_DER, ..
        "foregroundcolor", COLOR_INFO, ..
        "horizontalalignment", "left");

    tablaDerivada = uicontrol(ventanaPrincipal, ..
        "style", "listbox", ..
        "position", [38 55 590 350], ..
        "string", ["Iter | Derivada aprox. | Derivada ref. |  Error (%)"], ..
        "fontsize", 10, ..
        "fontname", "Monospaced", ..
        "backgroundcolor", [1 1 1], ..
        "horizontalalignment", "left");

    // ------------------------------------------------------------------------
    // PANEL DERECHO: SIMPSON
    // ------------------------------------------------------------------------
    uicontrol(ventanaPrincipal, ..
        "style", "frame", ..
        "position", [670 30 632 645], ..
        "backgroundcolor", COLOR_PANEL_INT);

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [688 630 595 30], ..
        "string", "2. INTEGRACION POR SIMPSON 3/8 EXTENDIDO", ..
        "fontsize", 15, ..
        "fontweight", "bold", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", COLOR_TITULO_INT, ..
        "horizontalalignment", "center");

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [690 594 100 23], ..
        "string", "Funcion f(x):", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", COLOR_TITULO_INT, ..
        "horizontalalignment", "left");

    txtIntFuncion = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [792 590 475 30], ..
        "string", "exp(x)", ..
        "fontsize", 11, ..
        "backgroundcolor", [1 1 1], ..
        "horizontalalignment", "left");

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [690 550 25 23], ..
        "string", "a:", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", COLOR_TITULO_INT, ..
        "horizontalalignment", "left");

    txtIntA = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [718 546 75 30], ..
        "string", "0", ..
        "backgroundcolor", [1 1 1]);

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [807 550 25 23], ..
        "string", "b:", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", COLOR_TITULO_INT, ..
        "horizontalalignment", "left");

    txtIntB = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [835 546 75 30], ..
        "string", "0.2", ..
        "backgroundcolor", [1 1 1]);

    uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [925 550 105 23], ..
        "string", "Error max. (%):", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", COLOR_TITULO_INT, ..
        "horizontalalignment", "left");

    txtIntError = uicontrol(ventanaPrincipal, ..
        "style", "edit", ..
        "position", [1030 546 222 30], ..
        "string", "0.001", ..
        "backgroundcolor", [1 1 1]);

    uicontrol(ventanaPrincipal, ..
        "style", "pushbutton", ..
        "position", [705 498 170 35], ..
        "string", "CALCULAR SIMPSON", ..
        "fontsize", 11, ..
        "fontweight", "bold", ..
        "backgroundcolor", COLOR_BTN_CALC_INT, ..
        "foregroundcolor", [1 1 1], ..
        "callback", "calcularSimpsonExtendido();");

    uicontrol(ventanaPrincipal, ..
        "style", "pushbutton", ..
        "position", [905 498 140 35], ..
        "string", "CARGAR EJEMPLO", ..
        "backgroundcolor", COLOR_BTN_EJEMPLO, ..
        "foregroundcolor", [0.30 0.20 0.02], ..
        "callback", "ejemploSimpson();");

    uicontrol(ventanaPrincipal, ..
        "style", "pushbutton", ..
        "position", [1080 498 140 35], ..
        "string", "LIMPIAR TODO", ..
        "backgroundcolor", COLOR_BTN_LIMPIAR, ..
        "foregroundcolor", [1 1 1], ..
        "callback", "limpiarSimpson();");

    lblIntReferencia = uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [690 462 590 24], ..
        "string", "Integral de referencia (intg): --", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", COLOR_TITULO_INT, ..
        "horizontalalignment", "left", ..
        "fontweight", "bold");

    lblIntResultado = uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [690 438 590 24], ..
        "string", "Ultima aproximacion: --", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", [0.25 0.25 0.25], ..
        "horizontalalignment", "left");

    lblIntEstado = uicontrol(ventanaPrincipal, ..
        "style", "text", ..
        "position", [690 414 590 24], ..
        "string", "Estado: listo.", ..
        "backgroundcolor", COLOR_PANEL_INT, ..
        "foregroundcolor", COLOR_INFO, ..
        "horizontalalignment", "left");

    tablaIntegral = uicontrol(ventanaPrincipal, ..
        "style", "listbox", ..
        "position", [690 55 590 350], ..
        "string", ["Iter |    n    | Integral aprox. | Integral ref. |  Error (%)"], ..
        "fontsize", 10, ..
        "fontname", "Monospaced", ..
        "backgroundcolor", [1 1 1], ..
        "horizontalalignment", "left");
endfunction


// Iniciar la interfaz
crearInterfaz();
