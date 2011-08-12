# Hash.class_eval do
#   unless defined_method? :subset
#     def subset *keys, &block
#       keys = keys.first if keys.first.is_a? Array
#       h = {}    
#       if keys
#         self.each do |k, v|
#           h[k] = v if keys.include? k
#         end
#       else
#         self.each do |k, v|
#           h[k] = v if block.call k
#         end
#       end
#       h
#     end
#   end
#   
#   unless defined_method? :reverse_merge
#     def reverse_merge(other_hash)
#       other_hash.merge(self)
#     end
# 
#     def reverse_merge!(other_hash)
#       merge!(other_hash){|k,o,n| o }
#     end
#   end  
# end