shader_type canvas_item;
uniform bool flip_h = false;
uniform bool flip_v = false;
uniform float progress : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float x_end_factor : hint_range(0.5, 3.0, 0.001) = 2.0;
uniform float y_end_factor : hint_range(-3.0, 1.0, 0.001) = -1.5;
uniform float reverse_dark : hint_range(0.2, 1.0, 0.01) = 0.75;
const vec2 scale = vec2(1.,1.);

vec2 Line2point(vec2 linePoint,vec2 lineDire,vec2 point) {
	lineDire = normalize(lineDire);
	vec2 line2Ori = - linePoint - dot(-linePoint,lineDire)*lineDire;
	vec2 p2Ori = - point - dot(-point,lineDire)*lineDire;
	return line2Ori-p2Ori;
	}

vec4 ColorWithA(vec4 oldCol,vec4 newCol){
	vec4 finalCol;
	if((newCol.a + oldCol.a)>=1.)
	{
		finalCol.rgb = newCol.rgb ;
		finalCol.a =1.0;
	}
	else{
		finalCol.rgb = newCol.a/(newCol.a + oldCol.a)*newCol.rgb + oldCol.a/(newCol.a + oldCol.a)*oldCol.rgb;
		finalCol.a = oldCol.a +newCol.a;
		}
	return 	finalCol;
	}

void fragment() {
    vec2 uv = UV;
	vec2 mouse_pos = (1.0 / TEXTURE_PIXEL_SIZE) * vec2(x_end_factor * progress, (y_end_factor - 1.0) * progress + 1.0);

	if (flip_h) {uv.x = 1.0 - uv.x;}
	if (flip_v) {uv.y = 1.0 - uv.y;}

	vec4 finalColor = vec4(0.0); // Initialize with transparent color
	float scale_min = scale.x/scale.y;
	vec2 uv_max = vec2(scale_min,1.);
	float trueScale;
	if(scale.y<scale.x){
		scale_min = scale.y/scale.x;
		uv.y = uv.y * scale_min;
		uv_max = vec2(1.,scale_min);
		trueScale = scale.x;
		}
	else{
		uv.x = uv.x*scale_min;
		trueScale = scale.y;
	}

	vec2 pPos = uv / TEXTURE_PIXEL_SIZE * trueScale;
	if (mouse_pos.x>-0.0001)
	{
		vec2 left_bottom = vec2(0.,uv_max.y/TEXTURE_PIXEL_SIZE.y * trueScale);
		vec2 midpoint = (mouse_pos - left_bottom)/2. + left_bottom;
		vec2 midDirect = normalize(vec2(-(mouse_pos-left_bottom).y,(mouse_pos-left_bottom).x));
		//bg

		//pageback
		vec2 sharpPoint = vec2(0.,midpoint.y - midDirect.y/midDirect.x * midpoint.x);
		vec2 flipEdgeDire = normalize(sharpPoint - mouse_pos);
		//pagebackBottom
		vec2 sharpPointB = vec2(midpoint.x-midDirect.x/midDirect.y * (midpoint-left_bottom).y,left_bottom.y);
		vec2 flipEdgeDireB = normalize(sharpPointB - mouse_pos);

		float cyOriOff = length(mouse_pos-left_bottom);
		if (cyOriOff>100.) cyOriOff = 100.;
		float cyR = cyOriOff*2./PI;
		float pageHDire = PI/6.;
		vec2 midlineToP = Line2point(midpoint,midDirect,pPos);
		vec2 sideEdgeToP = Line2point(mouse_pos,flipEdgeDire,pPos);
		vec2 BottomEdgeToP = Line2point(mouse_pos,flipEdgeDireB,pPos);

		vec2 cyOriToP = midlineToP - normalize(mouse_pos- left_bottom)*cyOriOff;
		vec2 cyEdgeToP = midlineToP - normalize(mouse_pos- left_bottom)*(cyOriOff-cyR);

		bool atBG = (cyOriToP).x<=-0.01;
		bool atPageBack = !atBG&&(sideEdgeToP.y>0.)&&(BottomEdgeToP.x<=0.);
		bool atCy = cyEdgeToP.x >=0. && (cyOriToP).x<=0.;
		bool atCyPage = false;
		vec2 uvCy ;
		vec2 uvCyB ;

		float shadow = 1.;
		if (atCy){
			vec2 cyOri = pPos-cyOriToP;
			vec2 trueDis = cyR*  asin(length(cyOriToP)/cyR)*normalize(cyOriToP);
			vec2 truePos = cyOri+trueDis;

			vec2 sideEdgeToTP = Line2point(mouse_pos,flipEdgeDire,truePos);
			vec2 BottomEdgeToTP = Line2point(mouse_pos,flipEdgeDireB,truePos);
			uvCyB = truePos * TEXTURE_PIXEL_SIZE /trueScale;
			shadow *= 1.-pow(length(trueDis)/(cyR*PI/2.),3.);

			if ((BottomEdgeToTP.x<0.)&& (sideEdgeToTP.y>0.))
				{
					atCyPage = true;
					uvCy = vec2(length(sideEdgeToTP),left_bottom.y-length(BottomEdgeToTP))*TEXTURE_PIXEL_SIZE /trueScale;
				}

			if ((uvCyB.x > uv_max.x)||(uvCyB.y > uv_max.y)||(uvCyB.x <= 0.)|| (uvCyB.y <= 0.))
				atCy =false;
		}

    // Page
    if (!atBG && !atCy) {
		vec2 temp_uv = uv;
		if (flip_h) {temp_uv = vec2(1.0 - temp_uv.x, temp_uv.y);}
		if (flip_v) {temp_uv = vec2(temp_uv.x, 1.0 - temp_uv.y);}
        vec4 color = texture(TEXTURE, temp_uv);
        finalColor = color;
    }

    // cyBottom
    if (atCy) {
		vec2 temp_uv = uvCyB;
		if (flip_h) {temp_uv = vec2(1.0 - temp_uv.x, temp_uv.y);}
		if (flip_v) {temp_uv = vec2(temp_uv.x, 1.0 - temp_uv.y);}
        vec4 cyColor = texture(TEXTURE, temp_uv);
        finalColor = cyColor * reverse_dark;
    }

    if (atCyPage) {
		vec2 temp_uv = uvCy;
		if (flip_h) {temp_uv = vec2(1.0 - temp_uv.x, temp_uv.y);}
		if (flip_v) {temp_uv = vec2(temp_uv.x, 1.0 - temp_uv.y);}
        vec4 cyPageColor = texture(TEXTURE, temp_uv);
        cyPageColor.rgb *= reverse_dark;
        // Blend based on the alpha value of cyPageColor
        finalColor = mix(finalColor, cyPageColor, cyPageColor.a);
    }
	else if (atPageBack) {
        vec2 temp_uv = vec2(length(sideEdgeToP), left_bottom.y - length(BottomEdgeToP)) * TEXTURE_PIXEL_SIZE / trueScale;
		if (flip_h) {temp_uv = vec2(1.0 - temp_uv.x, temp_uv.y);}
		if (flip_v) {temp_uv = vec2(temp_uv.x, 1.0 - temp_uv.y);}
        vec4 pageBackColor = texture(TEXTURE, temp_uv);
        pageBackColor.rgb *= reverse_dark;  // 使掀起的反面稍微变暗
        // Blend based on the alpha value of pageBackColor
        finalColor = mix(finalColor, pageBackColor, pageBackColor.a);
    }

    COLOR = finalColor;
}

}