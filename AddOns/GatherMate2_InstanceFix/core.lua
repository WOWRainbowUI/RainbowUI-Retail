if not GatherMate2 then return end

GatherMate2.GetIDForNode = function(self, nodeType, name)
    if name and issecretvalue and issecretvalue(name) then
        return nil
    end
    return self.nodeIDs[nodeType][name]
end