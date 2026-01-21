// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

// TEST COMMENTO - Questo commento è stato aggiunto da Claude per testare la sincronizzazione con GitHub


function resize_screen() {
    var display_width = display_get_width();
    var display_height = display_get_height();
	
	
	// Assicuriamoci che siamo in modalità landscape, ad esempio su ipad vengono calcolati invertiti:
    if (display_width < display_height) {
        var temp = display_width;
        display_width = display_height;
        display_height = temp;
    }

    
    var aspect_ratio = display_width / display_height;
    var target_ratio = 16/9;
    var threshold_long = 1.1; // Soglia (rispetto a 16/9) per considerare uno schermo "lungo"
    var threshold_narrow = 1.35; // Soglia (rispetto ai 4/3) per considerare uno schermo più stretto di 4:3
   
   //nativo android stampa os_type = 4 quindi os_type == os_android
   
	var isMobile = (os_type == os_ios || os_type == os_android);

//os_type sempre 24 sui browser mobile/web/gx e  os_browser sempre -1 cioè browser_not_a_browser... quindi difficile discriminare per browser



    if (isMobile && (aspect_ratio > target_ratio * threshold_long)) {
		/////////  1) case mobile phones nativi android/ios /////////
		// Schermi "lunghi" (rapporto d'aspetto maggiore di 16:9 con threshold)
		// se ci faccio finire anche i non nativi mobile ci finiscono anche gli schermi windows widescreen e non va bene
	    global.x_factor_spr = 0.9;
		device_resize();		
    } else if (aspect_ratio < (4/3) * threshold_narrow) {
		/////////  2) case tablet/ipad non nativi (nativi da testare) /////////
	    // Schermi più stretti di 4:3 con una soglia
	    // Ridimensiona la GUI e la application surface senza margine
	    display_set_gui_size(display_width, display_height);
	    surface_resize(application_surface, display_width, display_height);  
	    // Imposta la dimensione della finestra al massimo disponibile
	    window_set_size(display_width, display_height); 		
		display_set_gui_maximise(1, 1, 0, 0); //sembra superflua
		global.x_factor_spr = 1.2;	
		
		//if (!window_get_fullscreen()) {
			//window_set_fullscreen(true); //sembra ignorata
		//}
    } else { 
		// qui ora ci stanno finendo tutti i non nativi non 4/3... 
		//per il momento lasciamo inalterato per gli schermi standard, tipo pc. senza zoomare
        // Per schermi con rapporto d'aspetto standard o vicino ad esso (16:9, 16:10)
        //display_set_gui_size(display_width, display_height);
        //surface_resize(application_surface, display_width, display_height);
        //window_set_size(display_width, display_height);
		global.x_factor_spr = 1;
    }
}

//device_resize chiamata all'interno della funzione di sopra (resize_screen)
function device_resize(){
	
	var display_width = display_get_width();
	var display_height = display_get_height();
    
	// Definiamo un margine di sicurezza (in pixel)
	var safety_margin = 70; // Puoi regolare questo valore
    
	// Calcoliamo le nuove dimensioni
	var new_width = display_width - safety_margin * 2;
	var new_height = display_height;
	var x_offset = safety_margin;
	var y_offset = 0;
    
	// Ridimensiona la GUI e la application surface
	display_set_gui_size(new_width, new_height);
	surface_resize(application_surface, new_width, new_height);
    
	// Imposta la dimensione della finestra al massimo disponibile
	window_set_size(display_width, display_height);
    
	// Posiziona l'application surface con i margini di sicurezza
	display_set_gui_maximise(1, 1, x_offset, y_offset);
    
	// Forza l'orientamento landscape
	//display_set_orientation(display_landscape);
	

}

