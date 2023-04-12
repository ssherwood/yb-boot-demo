package io.undertree.yb.domain.device;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface DeviceRepo extends JpaRepository<Device, Long> {
    Optional<Device> findByModel(String model);

    // @Query("SELECT DISTINCT name FROM people WHERE name NOT IN (:names)")
    //List<String> findNonReferencedNames(@Param("names") List<String> names);

    @Query("SELECT DISTINCT model FROM Device")
    List<String> findDistinctModels();

    //@Query("FROM Device ORDER BY model ASC")
    Optional<List<Device>> findAllByOrderByModelAsc();
}