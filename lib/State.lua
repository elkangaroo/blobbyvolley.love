local State = {}
State.__index = State

setmetatable(State, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:__construct(...)
    return self
  end
})

function State:__construct()
  self.currentState = nil
  self.stateToSwitchTo = nil
end

function State:step()
  if nil == self.currentState then
    -- self.currentState = MainMenuState()
    self.currentState = LocalGameState()
  end

  self.currentState:step_impl()

  -- check if we should switch to a new state
  if nil ~= self.stateToSwitchTo then
    print("switching to state " .. self.stateToSwitchTo:getStateName())

    self.currentState = self.stateToSwitchTo
    self.stateToSwitchTo = nil
  end
end

-- table<State> newState
function State:switchState(newState)
  self.stateToSwitchTo = newState
end

function State:getCurrenStateName()
  return self.currentState:getStateName()
end

return State
