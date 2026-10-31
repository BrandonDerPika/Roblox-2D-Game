local character = script.Parent

for _, descendant in character:GetDescendants() do
    if descendant:IsA("BasePart") then
        descendant.Transparency = 1
        descendant.CanCollide = false
    elseif descendant:IsA("Decal") then
        descendant.Transparency = 1
    end
end

