-- growth functions


---Sum of linear sequence from term n1 to n2 (inclusive)
---@param n1 integer term to start sequence at, >= 0
---@param n2 integer term to end sequence at, >= n1
---@return integer
local function lin_sum(n1, n2)
    return (n2 - n1 + 1) * (n1 + n2) / 2
end

---Sum of quadratic sequence from term n1 to n2 (inclusive)
---@param n1 integer term to start sequence at, >= 0
---@param n2 integer term to end sequence at, >= n1
---@return integer
local function quad_sum(n1, n2)
    return (n2 * (n2 - 1) * (2 * n2 + 1) / 6) - (n1 * (n1 - 1) * (2 * n1 + 1) / 6)
end

---@class Linear
---@field start integer The start of this series
---@field step integer The increment per step of the series
Linear = { start = 0, step = 0 }

---@class Quadratic
---@field a integer The quadratic term
---@field b integer The linear term
---@field c integer The constant term
Quadratic = { a = 0, b = 0, c = 0 }

---Create a Linear growth
---@param start integer
---@param step integer
---@return Linear
function Linear:new(start, step)
    this = { start = start, step = step }
    setmetatable(this, self)
    self.__index = self
    return this
end

--- Get the Nth value in this series
---@param n integer
---@return integer
function Linear:nth(n)
    return self.start + self.step * n
end

---Sum of arithmetic sequence from term a to a + n
---@param start integer
---@param num_terms integer
---@return integer
function Linear:sum(start, num_terms)
    return self.start * num_terms + self.step * num_terms * (start + (start + num_terms)) / 2
end

---Create a Quadratic growth
---@param start integer
---@param step integer
---@param step2 integer
---@return Quadratic
function Quadratic:new(start, step, step2)
    this = { c = start, b = step, a = step2 }
    setmetatable(this, self)
    self.__index = self
    return this
end

---Sum of quadratic sequence from term a to a + n
---@param start_term integer
---@param num_terms integer
---@return integer
function Quadratic:sum(start_term, num_terms)
    return self.c * num_terms +
        self.b * lin_sum(start_term, start_term + num_terms) +
        self.a * quad_sum(start_term, start_term + num_terms)
end

---Get the Nth value in this series
---@param n integer
---@return integer
function Quadratic:nth(n)
    return self.a * n * n + self.b * n + self.c
end

return {
    linear = Linear,
    quadratic = Quadratic,
}
