
module Saulabs
end
module Saulabs::Gauss
end
class Saulabs::Gauss::Distribution
  def *(other); end
  def +(other); end
  def -(other); end
  def /(other); end
  def ==(other); end
  def deviation; end
  def deviation=(arg0); end
  def equals(other); end
  def initialize(mean = nil, deviation = nil); end
  def mean; end
  def mean=(arg0); end
  def precision; end
  def precision=(arg0); end
  def precision_mean; end
  def precision_mean=(arg0); end
  def replace(other); end
  def self.absolute_difference(x, y); end
  def self.cdf(x); end
  def self.cumulative_distribution_function(x); end
  def self.erf(x); end
  def self.inv_cdf(x); end
  def self.inv_erf(p); end
  def self.log_product_normalization(x, y); end
  def self.log_ratio_normalization(x, y); end
  def self.pdf(x); end
  def self.probability_density_function(x); end
  def self.quantile_function(x); end
  def self.standard; end
  def self.with_deviation(mean, deviation); end
  def self.with_precision(mean, precision); end
  def self.with_variance(mean, variance); end
  def to_s; end
  def value_at(x); end
  def variance; end
  def variance=(arg0); end
end
class Saulabs::Gauss::TruncatedCorrection
  def self.exceeds_margin(perf_diff, draw_margin); end
  def self.v_exceeds_margin(perf_diff, draw_margin); end
  def self.v_within_margin(perf_diff, draw_margin); end
  def self.w_exceeds_margin(perf_diff, draw_margin); end
  def self.w_within_margin(perf_diff, draw_margin); end
end
module Saulabs::TrueSkill
end
module Saulabs::TrueSkill::Factors
end
class Saulabs::TrueSkill::Factors::Base
  def bind(variable); end
  def initialize; end
  def log_normalization; end
  def message_count; end
  def reset_marginals; end
  def send_message_at(idx); end
  def update_message_at(index); end
end
class Saulabs::TrueSkill::Factors::GreaterThan < Saulabs::TrueSkill::Factors::Base
  def initialize(epsilon, variable); end
  def log_normalization; end
  def update_message_at(index); end
end
class Saulabs::TrueSkill::Factors::Likelihood < Saulabs::TrueSkill::Factors::Base
  def initialize(beta_squared, variable1, variable2); end
  def log_normalization; end
  def update_helper(message1, message2, variable1, variable2); end
  def update_message_at(index); end
end
class Saulabs::TrueSkill::Factors::Prior < Saulabs::TrueSkill::Factors::Base
  def initialize(mean, variance, variable); end
  def log_normalization; end
  def update_message_at(index); end
end
class Saulabs::TrueSkill::Factors::WeightedSum < Saulabs::TrueSkill::Factors::Base
  def index_order; end
  def initialize(variable, ratings, weights); end
  def log_normalization; end
  def update_helper(weights, weights_squared, messages, variables); end
  def update_message_at(index); end
  def weights; end
  def weights_squared; end
end
class Saulabs::TrueSkill::Factors::Within < Saulabs::TrueSkill::Factors::Base
  def initialize(epsilon, variable); end
  def log_normalization; end
  def update_message_at(index); end
end
module Saulabs::TrueSkill::Layers
end
class Saulabs::TrueSkill::Layers::Base
  def build; end
  def factors; end
  def factors=(arg0); end
  def graph; end
  def graph=(arg0); end
  def initialize(graph); end
  def input; end
  def input=(arg0); end
  def output; end
  def output=(arg0); end
  def posterior_schedule; end
  def prior_schedule; end
end
class Saulabs::TrueSkill::Layers::IteratedTeamPerformances < Saulabs::TrueSkill::Layers::Base
  def build; end
  def factors; end
  def initialize(graph, team_perf_diff, team_diff_comp); end
  def multiple_team_loop_schedule; end
  def prior_schedule; end
  def two_team_loop_schedule; end
end
class Saulabs::TrueSkill::Layers::PerformancesToTeamPerformances < Saulabs::TrueSkill::Layers::Base
  def build; end
  def posterior_schedule; end
  def prior_schedule; end
end
class Saulabs::TrueSkill::Layers::PriorToSkills < Saulabs::TrueSkill::Layers::Base
  def build; end
  def initialize(graph, teams); end
  def prior_schedule; end
end
class Saulabs::TrueSkill::Layers::SkillsToPerformances < Saulabs::TrueSkill::Layers::Base
  def build; end
  def posterior_schedule; end
  def prior_schedule; end
end
class Saulabs::TrueSkill::Layers::TeamDifferenceComparision < Saulabs::TrueSkill::Layers::Base
  def build; end
  def initialize(graph, ranks); end
end
class Saulabs::TrueSkill::Layers::TeamPerformanceDifferences < Saulabs::TrueSkill::Layers::Base
  def build; end
  def initialize(graph); end
end
module Saulabs::TrueSkill::Schedules
end
class Saulabs::TrueSkill::Schedules::Base
  def visit(depth = nil, max_depth = nil); end
end
class Saulabs::TrueSkill::Schedules::Loop < Saulabs::TrueSkill::Schedules::Base
  def initialize(schedule, max_delta); end
  def visit(depth = nil, max_depth = nil); end
end
class Saulabs::TrueSkill::Schedules::Sequence < Saulabs::TrueSkill::Schedules::Base
  def initialize(schedules); end
  def visit(depth = nil, max_depth = nil); end
end
class Saulabs::TrueSkill::Schedules::Step < Saulabs::TrueSkill::Schedules::Base
  def initialize(factor, index); end
  def visit(depth = nil, max_depth = nil); end
end
class Saulabs::TrueSkill::Rating < Saulabs::Gauss::Distribution
  def activity; end
  def activity=(arg0); end
  def initialize(mean, deviation, activity = nil, tau = nil); end
  def tau; end
  def tau=(value); end
  def tau_squared; end
end
class Saulabs::TrueSkill::FactorGraph
  def self.new(arg0, arg1); end
  def beta; end
  def beta_squared; end
  def build_layers; end
  def draw_margin; end
  def draw_probability; end
  def epsilon; end
  def initialize(teams, ranks, options = nil); end
  def layers; end
  def ranking_probability; end
  def run_schedule; end
  def teams; end
  def update_skills; end
  def updated_skills; end
end
# class Predictor::Saulabs::TrueSkill::Rating
#   def self.new(arg0, arg1); end
#   def mean; end
# end

