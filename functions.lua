function _G.findIndex(array, target)
    for i, value in ipairs(array) do
        if value == target then
            return i
        end
    end
    return nil 
end