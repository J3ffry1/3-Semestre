// =============================================================================
// INTERFAZ DE LA SECANTE - DISEÑO PREMIUM STYLED
// =============================================================================
clear; clc;

function calcular_secante()
    // 1. Obtener los datos desde los campos de la interfaz
    str_fx   = get(UI_fx, "string");
    str_x0   = get(UI_x0, "string");
    str_x1   = get(UI_x1, "string");
    str_crit = get(UI_criterio, "value"); 
    str_lim  = get(UI_limite, "string");
    
    x0 = evstr(str_x0);
    x1 = evstr(str_x1);
    limite = evstr(str_lim);
    
    deff("y=f(x)", "y=" + str_fx);
    
    iter = 0;
    error_calc = %inf;
    raiz_hallada = %f;
    x_next = x1;
    
    historial_lineas = [];
    
    // 2. Bucle de cálculo (Tu lógica original)
    while (~raiz_hallada)
        iter = iter + 1;
        
        fx0 = f(x0);
        fx1 = f(x1);
        
        if (fx1 - fx0) == 0 then
            messagebox("División para cero detectada. Intente con otros puntos.", "Error", "error");
            return;
        end
        
        x_next = x1 - fx1 * (x1 - x0) / (fx1 - fx0);
        error_calc = abs(x_next - x1);
        
        // Formatear cada fila de la tabla
        linea = sprintf("   %-10s|   %-20s|   %-18s", string(iter), sprintf("%.7f", x_next), sprintf("%.7f", error_calc));
        historial_lineas = [historial_lineas; linea];
        
        x0 = x1;
        x1 = x_next;
        
        if str_crit == 1 then
            if error_calc < limite then
                raiz_hallada = %t;
            end
        else
            if iter >= limite then
                raiz_hallada = %t;
            end
        end
        
        if iter > 1000 then
            messagebox("El método divergió o excedió las 1000 iteraciones.", "Aviso", "warning");
            break;
        end
    end
    
    // 3. Actualizar la Lista de Iteraciones
    set(UI_tabla, "string", historial_lineas);
    
    // 4. Graficar en Ventana Independiente con Estilo Mejorado
    v_graf = findobj("figure_name", "Gráfica del Resultado");
    if isempty(v_graf) then
        figure("figure_name", "Gráfica del Resultado", "position", [620, 150, 650, 500]);
    else
        scf(v_graf);
    end
    clf(); 
    
    x_min = x_next - 4;
    x_max = x_next + 4;
    x_vals = linspace(x_min, x_max, 300);
    y_vals = feval(x_vals, f);
    
    plot(x_vals, y_vals, "b-", "linewidth", 2.5); // Línea azul más gruesa
    plot([x_min, x_max], [0, 0], "k--", "linewidth", 1.2); // Eje X discontinuo
    plot(x_next, f(x_next), "ro", "markersize", 8, "thickness", 3); // Raíz resaltada
    
    xgrid(color("lightgray"));
    title("Gráfica de f(x) = " + str_fx, "fontsize", 4, "fontname", "sansserif");
    xlabel("Eje X", "fontsize", 3);
    ylabel("Eje Y", "fontsize", 3);
endfunction

// =============================================================================
// DEFINICIÓN DE PALETA DE COLORES Y FUENTES (ESTILO MODERNO)
// =============================================================================
// Colores en formato [R, G, B] (Valores de 0 a 1)
COLOR_BG        = [0.94, 0.95, 0.97]; // Fondo gris claro azulado muy limpio
COLOR_PANEL     = [0.15, 0.20, 0.28]; // Azul marino oscuro para los encabezados
COLOR_TEXT_DARK = [0.10, 0.12, 0.15]; // Gris casi negro para lecturas descansadas
COLOR_WHITE     = [1, 1, 1];          // Blanco puro para cajas de texto
COLOR_BTN       = [0.08, 0.50, 0.35]; // Verde esmeralda para el botón de acción
COLOR_HEADER_T  = [0.22, 0.29, 0.39]; // Gris azulado intermedio para la tabla

FONT_TITLE  = "sansserif";
FONT_LABEL  = "sansserif";
FONT_MONO   = "monospaced";

// --- CONSTRUCCIÓN DE LA INTERFAZ ---
f_int = figure("figure_name", "Método de la Secante - Control Panel", ..
               "position", [100, 120, 500, 610], "menubar", "none", "toolbar", "none", ..
               "backgroundcolor", COLOR_BG);

// Título Principal de la Ventana
uicontrol(f_int, "style", "text", "string", "MÉTODO DE LA SECANTE", ..
          "position", [0, 560, 500, 50], "fontsize", 16, "fontweight", "bold", ..
          "fontname", FONT_TITLE, "horizontalalignment", "center", ..
          "backgroundcolor", COLOR_PANEL, "foregroundcolor", COLOR_WHITE);

// Campo: Función f(x)
uicontrol(f_int, "style", "text", "string", "Función Matemática f(x):", ..
          "position", [30, 515, 440, 20], "fontsize", 11, "fontweight", "bold", ..
          "fontname", FONT_LABEL, "horizontalalignment", "left", ..
          "backgroundcolor", COLOR_BG, "foregroundcolor", COLOR_TEXT_DARK);
UI_fx = uicontrol(f_int, "style", "edit", "string", "x^3 - 2*x - 5", ..
                  "position", [30, 485, 440, 30], "fontsize", 12, "fontname", FONT_MONO, ..
                  "backgroundcolor", COLOR_WHITE, "foregroundcolor", COLOR_TEXT_DARK);

// Campo: Puntos Iniciales (x0 y x1 alineados en la misma fila)
uicontrol(f_int, "style", "text", "string", "Punto Inicial (x0):", ..
          "position", [30, 445, 205, 20], "fontsize", 11, "fontweight", "bold", ..
          "fontname", FONT_LABEL, "horizontalalignment", "left", ..
          "backgroundcolor", COLOR_BG, "foregroundcolor", COLOR_TEXT_DARK);
UI_x0 = uicontrol(f_int, "style", "edit", "string", "2", ..
                  "position", [30, 415, 205, 30], "fontsize", 12, "fontname", FONT_MONO, ..
                  "backgroundcolor", COLOR_WHITE, "foregroundcolor", COLOR_TEXT_DARK);

uicontrol(f_int, "style", "text", "string", "Punto Inicial (x1):", ..
          "position", [265, 445, 205, 20], "fontsize", 11, "fontweight", "bold", ..
          "fontname", FONT_LABEL, "horizontalalignment", "left", ..
          "backgroundcolor", COLOR_BG, "foregroundcolor", COLOR_TEXT_DARK);
UI_x1 = uicontrol(f_int, "style", "edit", "string", "3", ..
                  "position", [265, 415, 205, 30], "fontsize", 12, "fontname", FONT_MONO, ..
                  "backgroundcolor", COLOR_WHITE, "foregroundcolor", COLOR_TEXT_DARK);

// Campo: Criterio de Parada
uicontrol(f_int, "style", "text", "string", "Criterio de Parada / Condición:", ..
          "position", [30, 375, 440, 20], "fontsize", 11, "fontweight", "bold", ..
          "fontname", FONT_LABEL, "horizontalalignment", "left", ..
          "backgroundcolor", COLOR_BG, "foregroundcolor", COLOR_TEXT_DARK);
UI_criterio = uicontrol(f_int, "style", "popupmenu", ..
                        "string", ["Por Error / Tolerancia", "Por Tendencia / Iteraciones"], ..
                        "position", [30, 345, 440, 30], "fontsize", 11, "fontname", FONT_LABEL, ..
                        "value", 1);

// Campo: Valor del Criterio
uicontrol(f_int, "style", "text", "string", "Valor del Criterio (Tolerancia o N° Iteraciones):", ..
          "position", [30, 305, 440, 20], "fontsize", 11, "fontweight", "bold", ..
          "fontname", FONT_LABEL, "horizontalalignment", "left", ..
          "backgroundcolor", COLOR_BG, "foregroundcolor", COLOR_TEXT_DARK);
UI_limite = uicontrol(f_int, "style", "edit", "string", "0.0001", ..
                      "position", [30, 275, 440, 30], "fontsize", 12, "fontname", FONT_MONO, ..
                      "backgroundcolor", COLOR_WHITE, "foregroundcolor", COLOR_TEXT_DARK);

// Botón de Acción Estilizado
btn_calcular = uicontrol(f_int, "style", "pushbutton", "string", "EFECTUAR CÁLCULO Y GRAFICAR", ..
                         "position", [30, 210, 440, 45], "fontsize", 12, "fontweight", "bold", ..
                         "fontname", FONT_TITLE, "callback", "calcular_secante()", ..
                         "backgroundcolor", COLOR_BTN, "foregroundcolor", COLOR_WHITE);

// --- SECCIÓN: HISTORIAL DE ITERACIONES ---
uicontrol(f_int, "style", "text", "string", "Historial de Iteraciones:", ..
          "position", [30, 175, 440, 20], "fontsize", 11, "fontweight", "bold", ..
          "fontname", FONT_LABEL, "horizontalalignment", "left", ..
          "backgroundcolor", COLOR_BG, "foregroundcolor", COLOR_TEXT_DARK);

// Encabezado de la tabla con color azul grisáceo y texto blanco
uicontrol(f_int, "style", "text", "string", "   Iter.     |   X_actual             |   Error Absoluto", ..
          "position", [30, 150, 440, 25], "backgroundcolor", COLOR_HEADER_T, "foregroundcolor", COLOR_WHITE, ..
          "fontname", FONT_MONO, "fontsize", 11, "horizontalalignment", "left");

// Caja de resultados (Listbox) limpia
UI_tabla = uicontrol(f_int, "style", "listbox", "string", [], ..
                     "position", [30, 25, 440, 125], "fontname", FONT_MONO, "fontsize", 11, ..
                     "backgroundcolor", COLOR_WHITE, "foregroundcolor", COLOR_TEXT_DARK);
