module Debug

	$debug_on = true

	class AssertError < RuntimeError
	end

	def Debug.disable()
		$debug_on = false
	end

	def Debug.assert
		if $debug_on
			works = yield
			raise AssertError.new() unless works
		end
	end
end
