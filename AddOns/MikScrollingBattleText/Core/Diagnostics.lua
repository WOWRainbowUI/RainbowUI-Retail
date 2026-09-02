local Diagnostics = {}
Diagnostics.__index = Diagnostics

function Diagnostics:New(output)
	return setmetatable({
		output = output or MikSBT.Print or print,
	}, self)
end

function Diagnostics:ReportError(owner, operation, message)
	self.output(string.format(
		"Component %s failed during %s: %s",
		tostring(owner),
		tostring(operation),
		tostring(message)
	))
end

MikSBT.Core = MikSBT.Core or {}
MikSBT.Core.Diagnostics = Diagnostics

return Diagnostics
