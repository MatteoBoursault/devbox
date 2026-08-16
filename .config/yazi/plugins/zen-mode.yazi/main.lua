local function setup()
	local old_layout = Tab.layout

	-- 1. Masquer l'en-tête (Header)
	if Header.redraw then
		Header.redraw = function()
			return {}
		end
	else
		Header.render = function()
			return {}
		end
	end

	-- 2. Masquer la barre de statut (Status bar)
	if Status.redraw then
		Status.redraw = function()
			return {}
		end
	else
		Status.render = function()
			return {}
		end
	end

	-- 3. Redimensionner la zone centrale pour occuper tout l'espace libéré
	Tab.layout = function(self, ...)
		self._area = ui.Rect({
			x = self._area.x,
			y = self._area.y - 1, -- Remonte d'une ligne vers le haut
			w = self._area.w,
			h = self._area.h + 2, -- S'étire de 2 lignes (1 en haut + 1 en bas)
		})
		return old_layout(self, ...)
	end
end

return { setup = setup }
