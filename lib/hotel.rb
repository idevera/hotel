require 'date'

module BookingSystem
  class Hotel
    attr_reader :rooms, :all_reservations, :block_reservations

    def initialize
      # I can access the list of all of the rooms in the hotel
      @rooms = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
      # A block is not available for reservation by the general public, nor can it be included in another block
      @all_reservations = []
      @block_reservations = []
    end
    # I can reserve a room for a given date range
    def create_reservation(name, check_in, check_out)
      available_rooms = check_avail_rooms_for(check_in, check_out) # Returns array of all available rooms
      if rooms_available?(available_rooms) # Your code should raise an exception when asked to reserve a room that is not available
        assigned_room = available_rooms[0] # Assign the first available room
        reservation = Reservation.new(name, assigned_room, check_in, check_out)
        @all_reservations << reservation
      end
    end

    def find_reservation(name)
      found_reservation = nil
      @all_reservations.each do |reservation|
        if reservation.class == BookingSystem::Reservation
          if reservation.name == name
            found_reservation = reservation
            return reservation
          end
        end
      end
      raise ArgumentError.new("No reservation was found") if found_reservation == nil
    end
    # I can create a block of rooms
    def reserve_block(reserved_for, check_in, check_out, num_of_rooms)
      check_room_input(num_of_rooms) # Raised to UI. Max of 5 rooms and no less than 1
      available_rooms = check_avail_rooms_for(check_in, check_out)
      if rooms_available?(available_rooms) # Will raise an ArgumentError for UI
        reserved_room_nums = available_rooms[0..num_of_rooms - 1] # Takes the first 5 rooms from all available rooms
        new_block = Block.new(reserved_for, check_in, check_out, reserved_room_nums)
        # Return only one block reservation and pass it into the @all_reservations array so that they cannot access the rooms
        @all_reservations << new_block
        @block_reservations << new_block
        return new_block # Returns all reserved rooms numbers for a block
      end
    end

    def find_block(reserved_name)
      block_found = nil
      @block_reservations.each do |block|
        if block.reserved_for == reserved_name
          block_found = block
          return block
        end
      end
      raise ArgumentError.new("Reservation for your requested block was not found. Please try again.") if block_found == nil
    end # def
    # As an administrator, I can reserve a room from within a block of rooms
    def reserve_room_in_block(reserved_name, num_to_book)
      found_block = find_block(reserved_name)
      check_num_of_rooms(found_block, num_to_book) # Raise ArgumentError to UI
      avail_rooms = avail_rooms_in_block(reserved_name) # Check which room numbers are available in the block
      now_reserved_in_block = avail_rooms[0..num_to_book - 1] # Book number of requested rooms in the current block
      remaining_rooms = avail_rooms - now_reserved_in_block # Remaining rooms in requested block
      found_block.update_block_rooms(remaining_rooms, now_reserved_in_block) # Updates available and reserved rooms in the requested block
    end
    # As an administrator, I can check whether a given block has any rooms available
    def avail_rooms_in_block(reserved_name)
      found_block = find_block(reserved_name)
      if found_block.avail_block_rooms.empty?
        raise ArgumentError.new("There are no more rooms available to reserve for this block")
      else
        return found_block.avail_block_rooms
      end
    end # def
    # I can view a list of rooms that are not reserved for a given date range
    def check_avail_rooms_for(next_check_in, next_check_out) # WAVE 2
      next_reservation = DateRange.new(next_check_in, next_check_out)
      check_dates(next_reservation)
      existing_booked_rooms = next_reservation.overlap?(@all_reservations)
      existing_booked_rooms.empty? ? @rooms : @rooms - existing_booked_rooms
    end
    # I can access the list of all_reservations for a specific date
    def all_reservations_on(date)
      current_reservations = []
      date = Date.parse(date)
      @all_reservations.each do |reservation|
        current_reservations << reservation if date >= reservation.check_in && date < reservation.check_out
      end
      return current_reservations
    end

    private

    def check_room_input(num_of_rooms)
      if num_of_rooms > 5 || num_of_rooms < 1
        raise ArgumentError.new ("You can only reserve up to a max of 5 rooms and at least 1 room when reserving a block")
      end
    end

    def rooms_available?(available_rooms)
      if available_rooms.empty?
        raise ArgumentError.new("No room available for your requested dates. Please choose another date") # Raise to UI
      else
        return true
      end
    end # def

    def check_num_of_rooms(found_block, num_to_book)
      raise ArgumentError.new("Please choose an appropriate number of rooms") if num_to_book > found_block.avail_block_rooms.length || num_to_book < 1
    end

    def check_dates(next_reservation) # Your code should raise an error when an invalid date range is provided
      raise ArgumentError.new("Invalid dates") if next_reservation.check_in > next_reservation.check_out
    end

  end # Class
end # BookingSystem
